class Jobs::Email::EmailEventAdminForAction

  @queue = :emails

  # the "orig_action_id" is the action that was in the same chain as the new action represented by "action_id"
  def self.perform(comment_id, event_id)
    comment = Comment.find comment_id
    event = Event.find event_id
    admin_rsvp = event.organizers_rsvps_list

    admin_rsvp.each do |rsvp|
      begin
        email = UserMailer.event_admin_message_notice(comment, rsvp.user, event) if rsvp.user != comment.user
        email.deliver if email
      rescue Exception => e
        next
      end
    end
  end
end