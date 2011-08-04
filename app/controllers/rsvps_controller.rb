# RSVPs for the currently logged in user, for a given Event (by :event_id)

class RsvpsController < ApplicationController
  before_filter :store_current_path, :only => [:new, :edit]
  before_filter :authenticate_user!
  before_filter :require_event
  before_filter :require_rsvp
  before_filter :require_permission, :only => [:edit]

  def new
    if !@rsvp
      @rsvp = @event.rsvps.build
      @rsvp.user = current_user
    end
    
    @rsvp.status = Rsvp.statuses[:attending]
    if(@rsvp.save)

      if request.xhr?
        #render :partial => "buttons.js"
        render :update do |page|
          page.redirect_to event_path(@event, :invite => true)
        end
        return
      else
        redirect_to event_path(@event, :invite => true)
      end
    else
      puts "FUCK ME"
    end
  end

  def edit
    if !@rsvp
      @rsvp = @event.rsvps.build
      @rsvp.user = current_user
    end

    @rsvp.status = Rsvp.statuses[:not_attending]
    if(@rsvp.save)
      render :partial => "buttons.js"
      return
    else
      puts "FUCK ME"
    end
  end

  protected

  def require_event
    @event = Event.find params[:event_id].to_i
  end

  def require_rsvp
    @rsvp = @event.rsvps.by_user(current_user).first if current_user
  end

  def require_permission    
    #raise ActiveRecord::RecordNotFound if !@event.editable?(current_user)
  end
end
