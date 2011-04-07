class EventsController < ApplicationController

  before_filter :load_event_types, :only => [:index]
  before_filter :require_permission, :only => [:edit, :update]
  before_filter :authenticate_user!, :only => [:create, :edit, :update]
  before_filter :load_activity, :only => [:new] # for event created through activity stream

  # FIND EVENT PAGE
  def index
    # For testing only:
    Time.zone = params[:my_tz] unless params[:my_tz].blank?

    # Use the query params to find events (ideally this should be ONE SQL query with pagination)
    find_events
  end

  # EVENT DETAIL PAGE
  def show
    @event = Event.find params[:id]
    @rsvp = @event.rsvps.by_user(current_user).first if current_user
    @activities = @event.activities.newest_first.all # TODO: paginate @activities here (page = 1)
    @comment = @event.comments.build
  end

  #EVENT CREATE/EDIT PAGES
  def new
    @event = Event.new
    @event.location ||= Location.new
    @event.activity = @activity # nil if no @activity (which is desired)
    prepare_for_form
  end

  def create
    @event = Event.new params[:event]
    @event.user = current_user if current_user # TODO: remove if statement when enforced.

    if @event.save
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
    @event.attributes = params[:event]
    
    if @event.save
      redirect_to @event
    else
      prepare_for_form
      render :new
    end
  end

  protected

  def require_permission
    @event = Event.find params[:id]

    raise ActiveRecord::RecordNotFound if !@event.editable_by?(current_user)
  end

  def load_event_types
    @event_types ||= EventType.order('name').all
  end

  def load_activity
    # TODO: Perhaps creation through activity should be a separate controller/resource:  "/activities/x/events/new"
    @activity = Activity.find_by_id params[:activity_id].to_i if params[:activity_id]
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

  def find_events
    @events = Event

    radius = params[:radius].blank? ? 20 : params[:radius].to_i

    @events = @events.near(params[:location], radius, :order => "distance") unless params[:location].blank?
    @events = @events.of_type(params[:types]) unless params[:types].blank?

    # The "days of the week" should be for all time and NOT within the bounds of the date range.
    # which means they are an OR condition and not an AND condition to the query - KV
    if params[:days].blank?
      @events = @events.on_or_after_date(params[:from_date]) unless params[:from_date].blank?
      @events = @events.on_or_before_date(params[:to_date]) unless params[:to_date].blank?
    else
      @events = @events.on_days_or_in_date_range(params[:days], params[:from_date], params[:to_date])
    end

    # to_time and from_time are in integer (minute) format. 1439 = 11:59 PM (the day has 1440 minutes) - KV
    @events = @events.at_or_after_time_of_day(params[:from_time]) unless params[:from_time].blank?
    @events = @events.at_or_before_time_of_day(params[:to_time]) unless params[:to_time].blank?

    @events = @events.all # this executes a full search, which is bad, we want to paginate (eventually) - KV
  end

end
