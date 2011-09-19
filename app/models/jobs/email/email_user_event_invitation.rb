class Jobs::Email::EmailUserEventInvitation

  @queue = :emails

  def self.perform(invitation_id)
    invitation = EventRsvp.find invitation_id
    unless invitation # incase that transaction its in is not yet COMMITted in the sql db
      sleep 2
      invitation = EventRsvp.find invitation_id # last try since .find throws an exception if not found
    end
    
    to_user = invitation.user
    event = invitation.event

    # make sure the user has not already RSVP'd to the event they are being invited to
    if to_user.email? && invitation.status == EventRsvp.statuses[:invited]
      email = UserMailer.event_invitation_notice(invitation)
      email.deliver
    end
  end
end