class Jobs::EmailUserSubscriptionDigest

  @queue = :emails

  MAX_ACTIONS = 100

  def self.perform(subscription_id, start_time, end_time)
    subscription = SearchSubscription.find subscription_id

    redis = Redis.new
    key = "digest_actions:#{subscription.id}"
    action_ids = redis.zrevrange(key, 0, MAX_ACTIONS)
    
    actions = Action.find action_ids

    email = UserMailer.daily_subscription_digest(subscription, actions, start_time, end_time)
    email.deliver

    redis.del key # remove all data for the subscription
    
    redis.quit
  end
end