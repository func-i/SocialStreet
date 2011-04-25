class EventsController < ApplicationController

  before_filter :load_event_types, :only => [:index]
  before_filter :store_current_path, :only => [:index, :show, :new, :edit]
  before_filter :store_event_create, :only => [:create, :update]
  before_filter :authenticate_user!, :only => [:create, :edit, :update]
  before_filter :require_permission, :only => [:edit, :update]
  before_filter :load_action, :only => [:new] # for event created through activity stream

  # FIND EVENT PAGE
  def index
    # For testing only:
    Time.zone = params[:my_tz] unless params[:my_tz].blank?

    # Use the query params to find events (ideally this should be ONE SQL query with pagination)
    find_searchables
  end

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
    @event.searchable.searchable_date_ranges.build
    @event.searchable.searchable_event_types.build
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
      redirect_to @event
    else
      prepare_for_form
      render :new
    end
  end

  def edit
    prepare_for_form
    render :new
  end

  def update
    if create_or_edit_event(params, :edit)
      redirect_to @event
    else
      prepare_for_form
      render :new
    end
  end

  protected

  def store_event_create
    store_redirect(:controller => 'events', :action => 'create', :params => params)
  end

  def require_permission
    @event = Event.find params[:id]

    raise ActiveRecord::RecordNotFound if !@event.editable_by?(current_user)
  end

  def load_event_types
    @event_types ||= EventType.order('name').all
  end

  def load_action
    # TODO: Perhaps creation through action should be a separate controller/resource:  "/actions/x/events/new"
    @action = Action.find_by_id params[:action_id].to_i if params[:action_id]
  end

  def nav_state
    if params[:action] == 'index'
      @on_events = true
    elsif params[:action] == 'create' || params[:action] == 'new'
      @on_create_event = true
    end
  end

  def prepare_for_form
    load_event_types
  end

  def find_searchables
    @searchables = Searchable

    radius = params[:radius].blank? ? 20 : params[:radius].to_i

    @searchables = @searchables.of_type(params[:types]) unless params[:types].blank?

    @searchables = @searchables.on_days_or_in_date_range(params[:days], params[:from_date], params[:to_date], params[:inclusive])

    # to_time and from_time are in integer (minute) format. 1439 = 11:59 PM (the day has 1440 minutes) - KV
    @searchables = @searchables.at_or_after_time_of_day(params[:from_time]) unless params[:from_time].blank?
    @searchables = @searchables.at_or_before_time_of_day(params[:to_time]) unless params[:to_time].blank?
    
    # GEO LOCATION SEARCHING
    unless params[:location].blank?
      group_by = Searchable.columns.map { |c| "searchables.#{c.name}" }.join(',')
      group_by += ',' + SearchableEventType.columns.map { |c| "searchable_event_types.#{c.name}" }.join(',') unless params[:types].blank?
      group_by += ',' + SearchableDateRange.columns.map { |c| "searchable_date_ranges.#{c.name}" }.join(',') if params[:days] || params[:from_day] || params[:to_day] || params[:to_time] || params[:from_time]
      @searchables = @searchables.near(params[:location], radius).group(group_by)
    end
    
    @searchables = @searchables.all # this executes a full search, which is bad, we want to paginate (eventually) - KV
    
  end

end
