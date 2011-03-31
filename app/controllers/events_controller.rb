class EventsController < ApplicationController

  #  before_filter :load_events

  def index
    # EVENT LIST PAGE
    @events = Event

    distance = params[:distance].blank? ? 20 : params[:distance].to_i

    @events = @events.near(params[:location], distance).order("distance") unless params[:location].blank?
    @events = @events.on_or_after_date(params[:from_date]) unless params[:from_date].blank?
    @events = @events.on_or_before_date(params[:to_date]) unless params[:to_date].blank?

    @events = @events.held_on_days(params[:days]) unless params[:days].blank?

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
