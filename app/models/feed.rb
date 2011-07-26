class Feed < ActiveRecord::Base
  @@reasons = {
    :connection => "Connection",
    :subscription => "Subscription"
  }.freeze
  cattr_accessor :reasons
  
  belongs_to :user
  belongs_to :head_action, :class_name => "Action"
  belongs_to :index_action, :class_name => "Action"


  def self.encode(feed)
    feed.to_json
  end
  
  def self.decode(feed)
    FeedItem.create_from_json(JSON.parse(feed))
  end

  def self.for_user(redis, user, count)
    results=redis.zrevrange "feed:#{user.id}", 0, count
    if results.size > 0
      results.collect {|r|
        Feed.find(r)
      }
    else
      results
    end
  end

  # push status to a specific feed
  def self.push(redis, user, feed)
    redis.zadd "feed:#{user.id}", "#{Time.now.to_i}", feed.id
  end

end