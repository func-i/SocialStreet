class DashboardController < ApplicationController
  def show
    if current_user
      redis = Redis.new
      @feed_items = Feed.for_user(redis, current_user, 20)
      redis.quit

      #Upcoming Events
      @upcoming_events = Event.attended_by_user(current_user).upcoming.order("starts_at")
      #@upcoming_events_remaining = @upcoming_events.count - 3
      #@upcoming_events = @upcoming_events.limit(3)

      #Invitations
      invitations = Invitation.to_user(current_user).all#TODO - Should only display invitations where the user does not have an rsvp and still_valid
      invitations_by_event = {}
      invitations.each do |invitation|
        (invitations_by_event[invitation.event] ||= []) << invitation unless Rsvp.for_event(invitation.event).by_user(current_user).first
      end
      #@invitations_remaining = invitations_by_event.count - 3
      #@invited_events = invitations_by_event.keys()[0,3]
      @invited_events = invitations_by_event.keys()

      #Feedback Records
      @feedbacks = Feedback.by_user(current_user).awaiting_response
    else
      redirect_to :explore
    end
  end
end
