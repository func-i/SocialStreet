class Jobs::Email::EmailAllUsersStreetmeetEvent

  @queue = :emails

  # the "orig_action_id" is the action that was in the same chain as the new action represented by "action_id"
  def self.perform
    users = User.where("email <> ''")
    event = Event.where(:promoted => true)
    smow = event.smow

    smow.update_attribute("emails_valid", users.size)

    i=0
    users.each do |user|
      begin
        email = UserMailer.streetmeet_of_the_week(smow, user.email)

        if email
          email.deliver
          i += 1
        end
      rescue Exception => e
        next
      end
    end

    # => Update SMOW emails sent for smows#index
    smow.update_attribute("emails_sent", i)

    # => Send summary email
    UserMailer.deliver_streetmeet_of_the_week_summary("Total users: #{users.size}<br/>Total successful emails: #{i}")

  end
end