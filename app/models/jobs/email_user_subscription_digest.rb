class Jobs::EmailUserSubscriptionDigest

  @queue = :emails

  MAX_ACTIONS = 100

  def self.perform(subscription_id)
    subscription = SearchSubscription.find subscription_id

    redis = Redis.new
    key = "digest_actions:#{subscription.id}"
    action_ids = redis.zrevrange(key, 0, MAX_ACTIONS)
    
    actions = Action.find action_ids

    email = UserMailer.subscription_summary_notice(subscription, actions, subscription.user)
    email.deliver

    redis.del key # remove all data for this subscription
    
    redis.quit
  end
end