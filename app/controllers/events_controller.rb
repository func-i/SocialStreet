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

    if request.xhr? && params[:page] # pagination request
      render :partial => 'new_page'
    else
      # => Attendees && Administrator objects
      @attendees_rsvps = @event.rsvps.attending_or_maybe_attending
      @attendees_rsvps = @attendees_rsvps.order_by_rank_to_user(current_user) if current_user
      @attendees_rsvps = @attendees_rsvps.all
      @administrators_rsvps = @event.rsvps.administrators
      @administrators_rsvps = @administrators_rsvps.order_by_rank_to_user(current_user) if current_user
      @administrators_rsvps = @administrators_rsvps.all
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
      @event_for_create.searchable.location = @action.searchable.location.clone
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
      #puts "redirecting"
      #redirect_to event_path(@event_for_create)

      if request.xhr?
        puts "rendering..."
        render :update do |page|
          page.redirect_to @event_for_create
        end
      else
        redirect_to event_path(@event_for_create)
      end
      #render :update do |page|
      # page.redirect_to event_path(@event_for_create, :invite => true)
      #end
      
    else
      prepare_for_form
      render :new
    end
  end

  def edit
    @event_for_edit = @event
    prepare_for_form

    if(@event.finishes_at)
      my_diff = @event.finishes_at.to_i - @event.starts_at.to_i
      puts my_diff
      my_remainder = my_diff / (60*60*24)
      puts my_remainder
      if(my_remainder >= 1)
        @duration_size = "Days"
        @duration = my_remainder
      else
        my_remainder = my_diff / (60*60)
        puts my_remainder
        if(my_remainder >= 1)
          @duration_size = "Hours"
          @duration = my_remainder
        else
          my_remainder = my_diff / (60)
          puts my_remainder
          @duration_size = "Minutes"
          @duration = my_remainder
        end
      end
    end
  end

  def update

    @event.searchable.searchable_event_types.destroy_all
    @event_for_edit = @event

    
    if create_or_edit_event(params, :edit)
      Resque.enqueue(Jobs::Email::EmailUserEditEvent, @event.id)
      if request.xhr?
        puts "rendering..."
        render :update do |page|
          page.redirect_to @event
        end
      else
        redirect_to event_path(@event)
      end

    else
      prepare_for_form
      render :edit
    end
  end

  def destroy
    puts "I'm deleting shit..."
    event = Event.find params[:id]

    

    #raise ActiveRecord::RecordNotFound if !event.can_edit?(current_user)

    #event.canceled = true
    #event.save
    
    event.update_attribute('canceled', true)

    if(event.upcoming)
      Resque.enqueue(Jobs::Email::EmailUserCancelEvent, event.id)
    end

    redirect_to :root
  end

  def post_to_facebook
    @event = Event.find params[:id]

    @rsvp = @event.rsvps.by_user(current_user).first if current_user
    if @rsvp.nil?
      @rsvp = @event.rsvps.create!(:status => "Interested", :user => current_user)
    end
    
    unless @rsvp.posted_to_facebook?
      if @event.photo?
        photo_url = @event.photo.thumb.url
      elsif !@event.event_types.blank? && et = @event.event_types.detect {|et| et.image_path? }
        photo_url = et.image_path
      else
        photo_url = '/images/event_types/streetmeet' + (rand(8) + 1).to_s + '.png'
      end

      @rsvp.user.post_to_facebook_wall(
        :picture => "http://www.socialstreet.com#{photo_url}",
        :link => "http://www.socialstreet.com/events/#{@event.id}",
        :name => @event.title,
        :caption => "Brought to you by SocialStreet",
        :description => @event.name.blank? ? "" : @event.title_from_parameters(true),
        :message => "Checkout this StreetMeet on SocialStreet!",
        :type => "link"
      )
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
      @searchables = @searchables.matching_keywords(params[:event][:searchable_attributes][:keywords].reject{|k| k.blank?}, false)
      @searchables = @searchables.in_bounds(bounds[0],bounds[1],bounds[2],bounds[3]).order("searchables.created_at DESC")
      @searchables = @searchables.where(:ignored => false)
    end
    
  end

  def show_attendees
    @event = Event.find params[:id]
    
  end

  def invite_people
    @event = Event.find params[:id]
    
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
    @event_types = EventType.order('name').all
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

  def index
    
  end


end
