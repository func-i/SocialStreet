class Feed
  def self.encode(feed)
    feed.to_json
  end
  
  def self.decode(feed)
    FeedItem.create_from_json(JSON.parse(feed))
  end

  def self.for_user(redis, user, count)
    #    TmpFeedItem.where(:user_id => user.id).order(:last_touched).limit(count).all

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
#    feed_obj = TmpFeedItem.where(:user_id => user.id, :action_id => feed.action_id, :event_id => feed.event_id, :feed_type => feed.feed_type).first
#
#    if feed_obj.blank?
#      feed_obj = TmpFeedItem.new(:user_id => user.id, :feed_type => feed.feed_type, :action_id => feed.action_id, :event_id => feed.event_id, :inserted_because => feed.inserted_because)
#    end
#
#    feed_obj.last_touched = Time.zone.now
#
#    feed_obj.save
  end

end