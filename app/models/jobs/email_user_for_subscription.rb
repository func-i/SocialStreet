class Jobs::EmailUserForSubscription

  @queue = :emails

  def self.perform(subscription_id, action_id)
    subscription = SearchSubscription.find subscription_id
    action = Action.find action_id
    user = subscription.user
    
    email = UserMailer.subscription_instant_notice(subscription, action, user)

#    if action.action_type == Action.types[:event_created]
#      event = action.event
#      email = UserMailer.event_creation_notice(user, event)
#    elsif action.action_type == Action.types[:search_comment]
#      comment = action.reference
#      email = UserMailer.search_comment_notice(user, comment)
#    elsif action.action_type == Action.types[:action_comment]
#      comment = action.reference
#      email = UserMailer.action_comment_notice(user, comment, nil)
#    end
    
    email.deliver if email
  end
end