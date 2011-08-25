class Jobs::EmailUserWelcomeNotice

  @queue = :emails

  def self.perform(user_id)
    user = User.find_by_id user_id
    unless user && user.email # incase that transaction its in is not yet COMMITted in the sql db
      sleep 2
      user = User.find_by_id user_id
    end
    
    email = UserMailer.user_welcome_notice(user)
    email.deliver
  end
end