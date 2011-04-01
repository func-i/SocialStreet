class EventsController < ApplicationController

   before_filter :load_event_types

  def index
    # For testing only:
    Time.zone = params[:my_tz] unless params[:my_tz].blank?

    # EVENT LIST PAGE
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

  def show
    # EVENT DETAIL PAGE
  end

  protected

  def load_event_types
    @event_types = EventType.order('name').all
  end

  def nav_state
    @on_events = true
  end

end
