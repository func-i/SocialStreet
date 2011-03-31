class EventsController < ApplicationController

  #  before_filter :load_events

  def index
    # EVENT LIST PAGE
    @events = Event

    distance = params[:distance].blank? ? 20 : params[:distance].to_i

    @events = @events.near(params[:location], distance).order("distance") unless params[:location].blank?
    
    if params[:days].blank?
      @events = @events.on_or_after_date(params[:from_date]) unless params[:from_date].blank?
      @events = @events.on_or_before_date(params[:to_date]) unless params[:to_date].blank?
    else
      @events = @events.on_days_or_in_date_range(params[:days], params[:from_date], params[:to_date])
    end

    

    @events = @events.all
  end

  def show
    # EVENT DETAIL PAGE
  end

  protected

  
  def nav_state
    @on_events = true
  end

end
