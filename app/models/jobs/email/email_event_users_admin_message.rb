class Jobs::Email::EmailEventUsersAdminMessage

  @queue = :emails

  # the "orig_action_id" is the action that was in the same chain as the new action represented by "action_id"
  def self.perform(event_id, message)
    event = Event.find event_id
    if event
      event.event_rsvps.attending.each do |attendee|
        UserMailer.deliver_event_admin_message_to_attendee(event, attendee, message)
      end
    end    
  end
end