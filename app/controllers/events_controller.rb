class EventsController < ApplicationController

  before_filter :store_current_path, :only => [:show, :new, :edit]
  before_filter :store_event_create, :only => [:create, :update]
  before_filter :authenticate_user!, :only => [:create, :edit, :update, :destroy, :post_to_facebook]
  before_filter :require_editable_event, :only => [:edit, :update, :destroy]
  before_filter :load_action, :only => [:new] # for event created through activity stream

  # EVENT DETAIL PAGE
  def show
    @event = Event.find params[:id]
    @rsvp = @event.rsvps.by_user(current_user).first if current_user
    @actions = @event.actions.newest_first.all # TODO: paginate @actions here (page = 1)
    @comment = @event.comments.build
  end

  #EVENT CREATE/EDIT PAGES
  def new
    @event = Event.new
    @event.searchable ||= Searchable.new
    @event.searchable.location ||= Location.new
    # start/end datetimes are no longer defaulted in the model
    @event.searchable.searchable_date_ranges.build({ 
        :starts_at => Time.zone.now.advance(:hours => 3).floor(15.minutes),
        :ends_at => Time.zone.now.advance(:hours => 6).floor(15.minutes)
      })
    @event.action = @action # nil if no @action (which is desired)
    if session[:stored_params]
      @event.attributes = session[:stored_params] # event params
      @event.valid?
      session[:stored_params] = nil
    end
    
    prepare_for_form
  end

  def create
    if create_or_edit_event(params, :create)
      redirect_to [:new, @event, @event.rsvps.first, :invitation], :notice => "Your event is created. You can invite some of your friends below."
    else
      prepare_for_form
      render :new
    end
  end

  def edit
    prepare_for_form
  end

  def update
    if create_or_edit_event(params, :edit)
      redirect_to @event
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
    
    flash[:notice] = "This event's information has been posted to your wall"

    redirect_to @event
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

      @searchables = Searchable.scoped
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

end
