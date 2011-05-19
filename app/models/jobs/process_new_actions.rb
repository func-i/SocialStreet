# Create the initial connections via facebook
class Jobs::CleanupDashboardSet

  @queue = :actions

  CONNECTION_RANK_LIMIT_EVENT_CREATE = 40
  CONNECTION_RANK_LIMIT_EVENT_RSVP = 30
  CONNECTION_RANK_LIMIT_COMMENT = 20

  def self.perform(action_id)
    action = Action.find(action_id)

    #Add action to any user who has subscribed to it
    handle_subscriptions(action)

    #Add to any user who was part of the action chain
    handle_action_chain(action)

    #Add to any user who is connected to the actor
    handle_connections(action)

  end

  def handle_connections(an_action)
    #Handle:
    # => Event Creation
    # => RSVP
    # => Comments (event, action/replies, profile and search filter)
    feed = FeedItem.new
    
    if action.action_type == Action.types[:event_created]
      #Event Create - set event id
      feed.feed_type = FeedItem.types[:event_created]
      feed.event_id = an_action.event_id

      connections = Connection.to_user(an_action.user).ranked_less_or_eq(CONNECTION_RANK_LIMIT_EVENT_CREATE)

    elsif action.action_type == Action.types[:event_rsvp_attending]
      #RSVP - set event id
      feed.feed_type = FeedItem.types[:event_rsvp]
      feed.event_id = actan_action.event_id

      connections = Connection.to_user(an_action.user).ranked_less_or_eq(CONNECTION_RANK_LIMIT_EVENT_CREATE)
    else
      #Comments - set base action_id
      feed.feed_type = FeedItem.types[:comment]
      feed.action_id = an_action.action.id

      connections = Connection.to_user(an_action.user).ranked_less_or_eq(CONNECTION_RANK_LIMIT_COMMENT)
    end

    redis = Redis.new

    connections.all.each do |connection|
      #add to dashboard
      Feed.push(redis, connection.user, feed)
    end

    redis.quit
  end

  def handle_action_chain(an_action)
    #Handle:
    # => comments on actions (the base action can appear twice in some peoples dashboards, fixme)
    # => events to action treads (will appear twice in some peoples dashboards, fixme)
    return false if an_action.action.blank?

    feed = FeedItem.new :feed_type => FeedItem.types[:comment], :action_id => an_action.action.id
    
    action_list = Actions.threaded_with(an_action)

    redis = Redis.new

    action_list.all.each do |action|
      #add to dashboard
      Feed.push(redis, action.user, feed)

      #add to email
      #TODO
    end

    redis.quit
  end

  def handle_subscriptions(action)
    #Actions that are delivered in subscriptions are:
    # => Event Creation
    # => Event Edit (not yet supported)
    # => Search Filter Comments

    if(action.action_type == Action.types[:event_created])
      event = action.event
      subscriptions = SearchSubscription.matching_event(event)

    elsif(action.action_type == Action.types[:search_comment]) #TODO action comments where reply to search comment)
      #TODO
    end

    subscriptions.each do |subscription|
      #Add to the user subscription email. Note that this could send the same event twice for two different subscriptions, make sure to handle

      #Add to the users dashboard
      Feed.push(redis.new, subscription.user, nil) #TODO
    end
  end
end