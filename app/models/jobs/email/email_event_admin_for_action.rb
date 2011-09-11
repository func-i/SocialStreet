class Jobs::Email::EmailEventAdminForAction

  @queue = :emails

  # the "orig_action_id" is the action that was in the same chain as the new action represented by "action_id"
  def self.perform(action_id, event_id)
    action = Action.find action_id
    event = Event.find event_id
    admin_rsvp = event.administrators_rsvps_list

    admin_rsvp.each do |rsvp|
      email = UserMailer.event_admin_message_notice(action, rsvp.user, event) if rsvp.user != action.user

      email.deliver if email
    end
  end
end