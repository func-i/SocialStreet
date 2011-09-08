class Jobs::Email::EmailUserForSubscription

  @queue = :emails

  def self.perform(subscription_id, action_id)
    subscription = SearchSubscription.find subscription_id
    action = Action.find action_id
    user = subscription.user
    
    email = UserMailer.subscription_instant_notice(subscription, action, user)
    
    email.deliver if email
  end
end