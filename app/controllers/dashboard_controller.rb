class DashboardController < ApplicationController
  def show
    @upcoming_events = Event.attended_by_user(current_user).upcoming.order("starts_at").all
    @invitations = Invitation.by_to_user(current_user).all

    #@passed_events = Event.attended_by_user(current_user).passed.order("start_at").all
  end
end
