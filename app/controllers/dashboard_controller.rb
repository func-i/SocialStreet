class DashboardController < ApplicationController
  def show
    if current_user
      redis = Redis.new
      @feed_items = Feed.for_user(redis, current_user, 20)
      redis.quit
      
      @upcoming_events = Event.attended_by_user(current_user).upcoming.order("starts_at").all

      invitations = Invitation.to_user(current_user).all#TODO - Should only display invitations where the user does not have an rsvp
      @invitations_by_event = {}
      invitations.each do |invitation|
        (@invitations_by_event[invitation.event] ||= []) << invitation unless Rsvp.for_event(invitation.event).by_user(current_user).first
      end
      
      @feedbacks = Feedback.by_user(current_user).awaiting_response
    else
      redirect_to :explore
    end
  end
end
