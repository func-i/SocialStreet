class DashboardController < ApplicationController
  def show
    if current_user

      @upcoming_events = Event.attended_by_user(current_user).upcoming.order("starts_at").all

      invitations = Invitation.to_user(current_user).all#TODO - Should only display invitations where the user does not have an rsvp
      @invitations_by_event = {}
      invitations.each do |invitation|
        (@invitations_by_event[invitation.event] ||= []) << invitation unless Rsvp.for_event(invitation.event).by_user(current_user).first
      end
      
      @feedbacks = Feedback.by_user(User.find(2)).awaiting_response
    else
      redirect_to :explore
    end
  end
end
