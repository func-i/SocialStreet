class EventsController < ApplicationController

#  before_filter :load_events

  def index
    # EVENT LIST PAGE
    @events = Event
    distance = params[:distance].blank? ? 20 : params[:distance].to_i
    @events = @events.near(params[:location], distance).order("distance") unless params[:location].blank?
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
