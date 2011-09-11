class Jobs::Email::EmailUserSubscriptionDigest

  @queue = :emails

  MAX_ACTIONS = 100

  def self.perform(subscription_id)
    subscription = SearchSubscription.find subscription_id
    return false unless subscription

    redis = Redis.new
    key = "digest_actions:#{subscription.id}"
    action_ids = redis.zrevrange(key, 0, MAX_ACTIONS)
    
    actions = Action.where(:id => action_ids).all

    email = UserMailer.subscription_summary_notice(subscription, actions, subscription.user)
    email.deliver unless actions.empty?

    redis.del key # remove all data for this subscription
    
    redis.quit
  end
end