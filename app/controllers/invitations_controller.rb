class InvitationsController < ApplicationController

  before_filter :load_event_and_rsvp

  # only support nested action that expects event and rsvp IDs
  # Note: It's actually allowing the creation of multiple invitations here
  def new
    load_connections

    @event.action.user_list.each do |user|
      if user != current_user && current_user.invitations.for_event(@event).to_user(user).blank?
        @rsvp.invitations.build :event => @event, :user => current_user, :to_user => user
      end
    end unless @event.action.blank?
    
    @invitations = @rsvp.invitations
  end

  def change
    load_connections

    @invitations = @rsvp.invitations
  end

  # Note: It's actually creating multiple invitations here
  def create
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

    num_invited = (params[:user_ids] || []).size + (params[:emails] || []).size
    # TODO: Handle validation issues with non-unique invitations (maybe?)
    redirect_to @event, :notice => "You've invited #{num_invited} of your friends to this event. [[Link to modify invitations]]"
  end

  protected

  def load_event_and_rsvp
    @event = Event.find params[:event_id].to_i
    @rsvp = @event.rsvps.find params[:rsvp_id].to_i
  end

  def load_connections
    @connections = current_user.connections.most_relevant_first.limit(30).all
  end

end
