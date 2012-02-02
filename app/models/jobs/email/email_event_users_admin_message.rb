class Jobs::Email::EmailEventUsersAdminMessage

  @queue = :emails

  # the "orig_action_id" is the action that was in the same chain as the new action represented by "action_id"
  def self.perform(event_id, message)
    event = Event.find event_id
    if event
      event.event_rsvps.attending_or_maybe_attending.each do |attendee|
        begin
          unless attendee.user.email.blank?
            mail = UserMailer.event_admin_message_to_attendee(event, attendee, message)
            mail.deliver if mail
          end
        rescue Exception => e
          next
        end
      end
    end
  end
end