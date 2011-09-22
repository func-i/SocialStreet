class Jobs::Email::EmailUserCancelEvent

  @queue = :emails

  def self.perform(event_id)
    event = Event.find_by_id event_id
    
    event.event_rsvps.attending_or_maybe_attending.each do |rsvp|
      email = UserMailer.event_cancel_notice(rsvp.user, event)
      email.deliver
    end
  end
end