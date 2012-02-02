class Jobs::Email::EmailUserEditEvent

  @queue = :emails

  def self.perform(event_id)
    event = Event.find_by_id event_id
    
    event.event_rsvps.attending_or_maybe_attending.each do |rsvp|
      begin
        email = UserMailer.event_edit_notice(rsvp.user, event)
        email.deliver
      rescue Exception => e
        next
      end
    end
  end
end