# Create the initial connections via facebook
class Crons::WeeklySubscriptionDigester

  # Expects to be run once a day
  def self.run
    start_time = Time.zone.now.beginning_of_week.beginning_of_day
    end_time = Time.zone.now.end_of_day
    
    redis = Redis.new
    #    SearchSubscription.daily.find_each(:batch_size => 50) do |subscription|
    keys = redis.keys 'digest_actions:*'
    keys.each do |key|
      # remove the "digest_actions:" part of the key and you get the subscription id
      if subscription = SearchSubscription.daily.find_by_id(key.gsub('digest_actions:', '').to_i)
        if redis.zcard("digest_actions:#{subscription.id}").to_i > 0
          Resque.enqueue Jobs::EmailUserSubscriptionDigest, subscription.id, start_time, end_time
        end
      end
    end
    redis.quit
    
  end

end