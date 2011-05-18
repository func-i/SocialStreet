class Feed
  def self.encode(feed)
    feed.to_json
  end
  
  def self.decode(feed)
    JSON.parse(feed)
  end

  def self.for_user(redis, user, count)
    results=redis.zrevrange "feed:#{user.id}", 0, count
    if results.size > 0
      results.collect {|r| Feed::decode(r)}
    else
      results
    end
  end

  # push status to a specific feed
  def self.push(redis, user, feed)
    redis.zadd "feed:#{user.id}", "#{Time.now.to_i}", Feed::encode(feed)
  end

end