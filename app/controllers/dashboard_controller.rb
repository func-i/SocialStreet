class DashboardController < ApplicationController
  def show
    @upcoming_events = Event.attended_by_user(current_user).upcoming.order("starts_at").all
    @invitations = Invitation.by_to_user(current_user).all #TODO - Should only display invitations where the user does not have an rsvp

    @feedback_records = Feedback.by_user(User.find(2)).awaiting_response
  end
end
