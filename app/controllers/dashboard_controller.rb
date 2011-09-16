class DashboardController < ApplicationController
  def show
    if current_user
      @page_title = "Home"

      #Upcoming Events
      @upcoming_events = Event.attended_by_user(current_user).upcoming.order("starts_at")

      #Invitations
      invitations = Invitation.to_user(current_user).all#TODO - Should only display invitations where the user does not have an rsvp and still_valid
      invitations_by_event = {}
      invitations.each do |invitation|
        rsvp = Rsvp.for_event(invitation.event).by_user(current_user).first
        (invitations_by_event[invitation.event] ||= []) << invitation if (!rsvp && invitation.event.upcoming)
      end
      @invited_events = invitations_by_event.keys()

      #Feedback Records
      @feedbacks = Feedback.by_user(current_user).awaiting_response

      #News feed
      @per_page = 20
      offset = ((params[:page] || 1).to_i * @per_page) - @per_page

      redis = Redis.new
      @feed_items = Feed.for_user(redis, current_user, offset, @per_page)

      if !params[:page]
        if @per_page - @feed_items.count > 0
          feed_default = Feed.for_user(redis, User.where(:username => "default_socialstreet_user").first, 0, @per_page - @feed_items.count);
          @feed_items += feed_default
          @feed_items = @feed_items.map{|fi| (fi && fi.head_action) ? fi : nil}.compact.uniq_by{|fi| fi.head_action.id}
        end
      end

      redis.quit

      total_count = Feed.count(redis, current_user)
      @num_pages = (total_count.to_f / @per_page.to_f).ceil

      @closest_signed_up_friends = current_user.connections.to_user_is_member.where("connections.facebook_friend = true").order("connections.rank ASC")
      @closest_signed_up_friends_remaining = @closest_signed_up_friends.count - 24
      @closest_signed_up_friends = @closest_signed_up_friends.limit(24).all

      @closest_connection_ex_facebook = current_user.connections.to_user_is_member.where("connections.facebook_friend = false").order("connections.rank ASC")
      @closest_connection_ex_facebook_remaining = @closest_connection_ex_facebook.count - 24
      @closest_connection_ex_facebook = @closest_connection_ex_facebook.limit(24).all

      @promoted_events = Event.where(:promoted => true).upcoming.limit(1).all
      @feed_items = @feed_items.reject{|fi| @promoted_events.include?(fi.head_action.event)}

      if request.xhr?
        if params[:page] # pagination request
          render :partial => 'new_page'
        else
          render :nothing => true
        end
      end
    else
      redirect_to :explore
    end
  end
end
