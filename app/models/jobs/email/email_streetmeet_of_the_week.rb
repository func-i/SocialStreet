class Jobs::Email::EmailStreetmeetOfTheWeek

  @queue = :emails

  # the "orig_action_id" is the action that was in the same chain as the new action represented by "action_id"
  def self.perform
    users = User.where("email <> ''")

    users.each do |user|
      email = UserMailer.streetmeet_of_the_week(user.email)
      email.deliver if email
    end
  end
end