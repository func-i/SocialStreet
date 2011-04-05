# RSVPs for the currently logged in user, for a given Event (by :event_id)

class RsvpsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :require_event
  before_filter :require_rsvp, :except => [:new, :create]

  def new

  end

  def edit

  end

  def update
    
  end

  def create

  end

  protected

  def require_event
    @event = Event.find params[:event_id].to_i
  end

  def require_rsvp
    @rsvp = @event.rsvps.by_user(current_user).find params[:id].to_i
  end

end
