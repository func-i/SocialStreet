class Jobs::EmailUserForSubscription

  @queue = :emails

  def self.perform(subscription_id, action_id)
    subscription = SearchSubscription.find subscription_id
    action = Action.find action_id
    user = subscription.user


    if action.action_type == Action.types[:event_created]
      event = action.event
      email = UserMailer.event_creation_notice(user, event, subscription)
      email.deliver
    elsif action.action_type == Action.types[:search_comment]
      comment = action.reference
      email = UserMailer.search_comment_notice(user, comment, subscription)
      email.deliver
    end
    
  end
end