class InvitationsController < ApplicationController


  # only support nested action that expects event and rsvp IDs
  # Note: It's actually allowing the creation of multiple invitations here
  def new
    @event = Event.find params[:event_id].to_i
    @rsvp = @event.rsvps.find params[:rsvp_id].to_i
    @connections = current_user.connections.most_relevant_first.limit(30).all
  end

  # Note: It's actually creating multiple invitations here
  def create
    @event = Event.find params[:event_id].to_i
    @rsvp = @event.rsvps.find params[:rsvp_id].to_i
    
    params[:emails].each do |email|
      if user = User.find_by_email(email)
        current_user.invitations.create :event => @event, :rsvp => @rsvp, :to_user => user
      else
        current_user.invitations.create :event => @event, :rsvp => @rsvp, :email => email
      end
    end unless params[:emails].blank?

    params[:user_ids].each do |user_id|
      if user = User.find_by_id(user_id)
        current_user.invitations.create :event => @event, :rsvp => @rsvp, :to_user => user
      end
    end unless params[:user_ids].blank?

    # TODO: Handle validation issues with non-unique invitations (maybe?)
    redirect_to @event, :notice => "You've RSVP'd and invited your friends. [[Link to modify invitations]]"
  end

end
