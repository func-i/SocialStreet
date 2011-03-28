class EventsController < ApplicationController

  before_filter :load_events

  def index
    # EVENT LIST PAGE
  end

  def show
    # EVENT DETAIL PAGE
  end

  protected

  def load_events
    @events = Event.all
  end

  def nav_state
    @on_events = true
  end

end
