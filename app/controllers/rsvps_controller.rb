# RSVPs for the currently logged in user, for a given Event (by :event_id)

class RsvpsController < ApplicationController
  before_filter :store_current_path, :only => [:new, :edit]
  before_filter :authenticate_user!
  before_filter :require_event
  before_filter :require_rsvp, :except => [:create]
  before_filter :require_permission, :only => [:edit, :update]

  def new
    if @rsvp
      render :edit
    else
      @rsvp = @event.rsvps.build
    end
  end

  def edit

  end

  def update
    @rsvp.attributes = params[:rsvp]
    @rsvp.user = current_user
    if @rsvp.save
      #redirect_to @event, :notice => "You have successfully updated your RSVP for '#{@event.name}' to '#{@rsvp.status}'" + (@rsvp.waiting? ? '. You are on the waiting list' : '')
      redirect_to @event
    else
      render :new
    end
  end

  def create
    @rsvp = @event.rsvps.build(params[:rsvp])
    @rsvp.user = current_user
    if @rsvp.save
      #redirect_to [:new, @event, @rsvp, :invitation], :notice => "You have successfully RSVP'd to '#{@event.name}' as '#{@rsvp.status}'" + (@rsvp.waiting? ? '. You are on the waiting list' : '')
      redirect_to [:new, @event, @rsvp, :invitation]
    else
      render :new
    end
  end

  protected

  def require_event
    @event = Event.find params[:event_id].to_i
  end

  def require_rsvp
    @rsvp = @event.rsvps.by_user(current_user).first if current_user
    #Khurram: Please verify that I can change this line to the above
    #@rsvp = @event.rsvps.by_user(current_user).find params[:id].to_i
  end

  def require_permission    
    #raise ActiveRecord::RecordNotFound if !@event.editable?(current_user)
  end
end
