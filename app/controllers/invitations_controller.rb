class InvitationsController < ApplicationController


  # only support nested action that expects event and rsvp IDs
  def new
    @event = Event.find params[:event_id].to_i
    @rsvp = @event.rsvps.find params[:rsvp_id].to_i
    @connections = current_user.connections.most_relevant_first.limit(30).all
  end

  def create
    render :text => params.inspect
  end

end
