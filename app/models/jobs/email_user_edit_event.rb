class Jobs::EmailUserEditEvent

  @queue = :emails

  def self.perform(event_id)
    event = Event.find_by_id event_id
    
    event.attending_or_maybe_attendees_rsvps_list.each do |rsvp|
      email = UserMailer.event_edit_notice(rsvp.user, event)
      email.deliver
    end
  end
end