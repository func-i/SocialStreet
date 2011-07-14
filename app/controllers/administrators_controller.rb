# RSVPs for the currently logged in user, for a given Event (by :event_id)

class AdministratorsController < ApplicationController
  before_filter :store_current_path, :only => [:new, :edit]
  before_filter :authenticate_user!
  before_filter :require_event
  before_filter :require_permission, :only => [:edit, :update]

  def new
    @rsvps = @event.rsvps.all
    @connections = current_user.connections.most_relevant_first.all
    @administrator_rsvps = @rsvps.select &:administrator?
  end

  def create

    num_added, num_removed = 0,0

    params[:user_ids].each do |user_id|
      if user = User.find_by_id(user_id)
        rsvp = @event.rsvps.where(:user_id => user_id).first
        if rsvp && !rsvp.administrator?
          rsvp.administrator = true
          rsvp.save
          num_added += 1
        elsif rsvp.blank?
          rsvp = @event.rsvps.create :user => user, :administrator => true, :status => Rsvp.statuses[:maybe_attending]
          num_added += 1
        end
      end
    end unless params[:user_ids].blank?

    @event.rsvps.administrators.all.each do |rsvp|
      if !(params[:user_ids] || []).include? rsvp.user_id.to_s
        rsvp.administrator = false
        rsvp.save
        num_removed += 1
      end
    end

    #redirect_to @event, :notice => "Added #{num_added} and removed #{num_removed} Administrators."
    redirect_to @event
  end
  
  protected

  def require_event
    @event = Event.find params[:event_id].to_i
  end

  def require_permission
    raise ActiveRecord::RecordNotFound if @event.user != current_user
  end
end
