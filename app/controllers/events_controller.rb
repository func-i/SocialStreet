class EventsController < ApplicationController

  before_filter :store_current_path, :only => [:show, :edit, :post_to_facebook]
  before_filter :store_event_create, :only => [:create, :update]
  before_filter :ss_authenticate_user!, :only => [:create, :edit, :update, :destroy, :post_to_facebook]
  before_filter :require_editable_event, :only => [:edit, :update, :destroy]
  before_filter :load_action, :only => [:new] # for event created through activity stream

  # EVENT DETAIL PAGE
  def show
    @event = Event.find params[:id]
    @rsvp = @event.rsvps.by_user(current_user).first if current_user
    @comment = @event.comments.build

    # => Action list and pagination
    @actions = @event.actions.where(:action_type => Action.types[:event_comment]).newest_first
    @per_page = 10
    offset = ((params[:page] || 1).to_i * @per_page) - @per_page
    total_count = @actions.count
    @num_pages = (total_count.to_f / @per_page.to_f).ceil
    @actions = @actions.limit(@per_page).offset(offset)

    # => Attendees && Administrator objects
    @attendees_rsvps = @event.rsvps.attending_or_maybe_attending.order_by_rank_to_user(current_user).all
    @administrators_rsvps = @event.rsvps.administrators.order_by_rank_to_user(current_user).all

    if request.xhr? && params[:page] # pagination request
      render :partial => 'new_page'
    end

    @page_title = "Event - #{@event.title}"
  end

  #EVENT CREATE/EDIT PAGES
  def new
    @event_for_create = Event.new
    @event_for_create.searchable ||= Searchable.new
    @event_for_create.searchable.location ||= Location.new
    #start/end datetimes are no longer defaulted in the model
    @event_for_create.searchable.searchable_date_ranges.build({
        :starts_at => Time.zone.now.advance(:hours => 3).floor(15.minutes),
        :ends_at => Time.zone.now.advance(:hours => 6).floor(15.minutes)
      })
    @event_for_create.action = @action # nil if no @action (which is desired)

    if @action && @action.searchable && @action.searchable.location
      @event_for_create.searchable.location = @action.searchable.location
    end

    if session[:stored_params]
      @event_for_create.attributes = session[:stored_params] # event params
      @event_for_create.valid?
      session[:stored_params] = nil
    end
    
    prepare_for_form
  end

  def create
    if create_or_edit_event(params, :create)      
      render :update do |page|
        page.redirect_to event_path(@event_for_create, :invite => true)
      end
      
    else
      prepare_for_form
      render :new
    end
  end

  def edit
    @event_for_edit = @event
    prepare_for_form
  end

  def update

    @event.searchable.searchable_event_types.destroy_all
    @event_for_edit = @event
    
    if create_or_edit_event(params, :edit)
      render :update do |page|
        page.redirect_to event_path(@event)
      end
      #redirect_to @event
    else
      prepare_for_form
      render :edit
    end
  end

  def destroy
    if @event.cancellable?(current_user)
      if @event.cancel
        #TODO - send emails to everyone
      end
      redirect_to :root
    else
      raise "WHAT THE F***"
    end
  end

  def post_to_facebook
    @event = Event.find params[:id]

    @rsvp = @event.rsvps.by_user(current_user).first if current_user
    if @rsvp.nil?
      @event.rsvps.create!(:status => "Interested", :facebook => true, :user => current_user)
    else
      unless @rsvp.posted_to_facebook?
        @rsvp.facebook = true
        @rsvp.save
      end
    end

    if !request.xhr?
      redirect_to event_path(@event, :post_to_facebook => true)
    end
  end

  def load_events   

    @searchables = []

    # => Only search if there are keywords
    if params[:event] && params[:event][:searchable_attributes] && params[:event][:searchable_attributes][:keywords] && !params[:event][:searchable_attributes][:keywords].reject{|k| k.blank?}.blank?

      if params[:map_bounds].blank?
        params[:map_bounds] = "43.958661074786455,-78.99006997304684,43.362570924106635,-79.79756509023434"
      end

      params[:map_center] = "43.66061599944655,-79.3938175316406" if params[:map_center].blank?
      params[:map_zoom] = 9 unless params[:map_zoom]

      bounds = params[:map_bounds].split(",").collect { |point| point.to_f }

      @searchables = Searchable.explorable
      @searchables = @searchables.with_keywords(params[:event][:searchable_attributes][:keywords].reject{|k| k.blank?})
      @searchables = @searchables.in_bounds(bounds[0],bounds[1],bounds[2],bounds[3]).order("searchables.created_at DESC")
      @searchables = @searchables.where(:ignored => false)
    end
    
  end


  protected

  def store_event_create
    store_redirect(:controller => 'events', :action => 'create', :params => params)
  end

  def require_editable_event
    @event = Event.find params[:id]

    raise ActiveRecord::RecordNotFound if !@event.editable?(current_user)
  end

  def load_event_types
    @event_types ||= EventType.order('name').all
  end

  def load_action
    # TODO: Perhaps creation through action should be a separate controller/resource:  "/actions/x/events/new"
    @action = Action.find_by_id params[:action_id].to_i if params[:action_id]
  end

  def nav_state
    if params[:action] == 'create' || params[:action] == 'new'
      @on_create_event = true
    end
  end

  def prepare_for_form
    load_event_types
  end

  def load_invitations_objects
    
    if current_user.fb_friends_imported?
      load_connections

      @event.action.user_list.each do |user|
        if user != current_user && current_user.invitations.for_event(@event).to_user(user).blank?
          @rsvp.invitations.build :event => @event, :user => current_user, :to_user => user
        end
      end unless @event.action.blank?

      @invitations = @rsvp.invitations if @rsvp
     
    else
      redirect_to import_facebook_friends_connections_path(:return => new_event_rsvp_invitation_path(@event, @rsvp))
    end
  end

  def load_connections

    # => TODO: Add search user search functionality to endless pagination.

    @per_page_invitations = 24
    @offset_invitations = ((params[:page] || 1).to_i * @per_page_invitations) - @per_page_invitations

    # => TODO: see if you can take that inline string notation out
    @users = User.select("users.id, users.first_name, users.last_name, users.facebook_profile_picture_url, users.twitter_profile_picture_url").
      joins("LEFT OUTER JOIN connections ON users.id=connections.to_user_id AND connections.user_id=#{current_user.id}").
      where("users.id <> ?", current_user.id).
      where("(users.sign_in_count>0 OR connections.to_user_id IS NOT NULL)").
      group("users.id, users.first_name, users.last_name, users.facebook_profile_picture_url, users.twitter_profile_picture_url, connections.strength, connections.created_at").
      order("connections.strength DESC NULLS LAST, connections.created_at ASC NULLS LAST")

    @users = @users.with_keywords(params[:user_search]) unless params[:user_search].blank?
    @total_count_invitations = User.find_by_sql("SELECT COUNT(*) as total_count FROM (#{@users.to_sql}) as tableA").first.total_count.to_i

    @users = @users.
      limit(@per_page_invitations).
      offset(@offset_invitations)

    @num_pages_invitations = (@total_count_invitations.to_f / @per_page_invitations.to_f).ceil

  end


end
