# RSVPs for the currently logged in user, for a given Event (by :event_id)

class AdministratorsController < ApplicationController
  before_filter :store_current_path, :only => [:new, :edit]
  before_filter :authenticate_user!
  before_filter :require_event
  before_filter :require_permission, :only => [:edit, :update]

  def new
    @rsvps = Rsvp.for_event(@event).all
    @connections = current_user.connections.most_relevant_first.all
    @administrator_rsvps = Rsvp.for_event(@event).administrators.all
  end

  def create
    params[:user_ids].each do |user_id|
      if user = User.find_by_id(user_id)
        if rsvp = @event.rsvps.where(:user_id => user_id).first
          rsvp.administrator = true
          rsvp.save
        else
          rsvp = @event.rsvps.create :user => user, :administrator => true, :status => Rsvp.statuses[:maybe_attending]
        end
      end
    end unless params[:user_ids].blank?

    redirect_to @event, :notice => "BLAHHHH"

  end
  
  protected

  def require_event
    @event = Event.find params[:event_id].to_i
  end

  def require_permission
    raise ActiveRecord::RecordNotFound if @event.user != current_user
  end
end
