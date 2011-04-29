module InvitationsHelper

  def invited?(user)
    !@invitations.select {|i| i.to_user == user}.empty?
  end
end
