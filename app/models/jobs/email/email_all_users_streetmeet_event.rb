class Jobs::Email::EmailStreetmeetOfTheWeek

  @queue = :emails

  # the "orig_action_id" is the action that was in the same chain as the new action represented by "action_id"
  def self.perform
    users = User.where("email <> ''")

    puts users.size
    i=0
    users.each do |user|
      begin
        email = UserMailer.streetmeet_of_the_week(user.email)

        if email
          email.deliver
          puts i+=1
        end
      rescue Exception => e
        puts "error => #{e.message}"
        next
      end
    end
  end
end