# Create the initial connections via facebook
class Jobs::ProcessNewAction

  @queue = :actions

  CONNECTION_RANK_LIMIT_EVENT_CREATE = 40
  CONNECTION_RANK_LIMIT_EVENT_RSVP = 30
  CONNECTION_RANK_LIMIT_COMMENT = 20

  def self.perform(action_id)

    action = Action.find(action_id)
    redis = Redis.new
    
    #Add action to any user who has subscribed to it
    handle_subscriptions(redis, action)

    #Add to any user who was part of the action chain
    handle_action_chain(redis, action)

    #Add to any user who is connected to the actor
    handle_connections(redis, action)

    redis.quit
  end

  def self.handle_connections(redis, action)
    #Handle:
    # => Event Creation
    # => RSVP
    # => Comments (event, action/replies, profile and search filter)
    feed = FeedItem.new
    
    if action.action_type == Action.types[:event_created]
      #Event Create - set event id
      feed.feed_type = FeedItem.types[:event_created]
      feed.event_id = action.event_id

      connections = Connection.to_user(action.user).ranked_less_or_eq(CONNECTION_RANK_LIMIT_EVENT_CREATE)

    elsif action.action_type == Action.types[:event_rsvp_attending]
      unless action.user == action.event.user # if its the owner of the event, no need to log it
        #RSVP - set event id
        feed.feed_type = FeedItem.types[:event_rsvp]
        feed.event_id = action.event_id

        connections = Connection.to_user(action.user).ranked_less_or_eq(CONNECTION_RANK_LIMIT_EVENT_CREATE)
      end
    elsif action.action_type == Action.types[:event_comment] ||
        action.action_type == Action.types[:profile_comment] ||
        action.action_type == Action.types[:search_comment]
      #Comments - set base action_id
      feed.feed_type = FeedItem.types[:comment]
      feed.action_id = action.action.id

      connections = Connection.to_user(action.user).ranked_less_or_eq(CONNECTION_RANK_LIMIT_COMMENT)
    end

    connections.all.each do |connection|
      #add to dashboard
      Feed.push(redis, connection.user, feed)
    end unless connections.blank?

  end

  def self.handle_action_chain(redis, action)
    #Handle:
    # => comments on actions (the base action can appear twice in some peoples dashboards, fixme)
    # => events to action treads (will appear twice in some peoples dashboards, fixme)
    return false if action.action.blank?

    feed = FeedItem.new 
    feed.feed_type = FeedItem.types[:comment]
    feed.action_id = action.action.id
    
    action_list = Actions.threaded_with(action)

    action_list.all.each do |action|
      #add to dashboard
      Feed.push(redis, action.user, feed)

      #add to email
      #TODO
    end
  end

  def self.handle_subscriptions(redis, action)
    #Actions that are delivered in subscriptions are:
    # => Event Creation
    # => Event Edit (not yet supported)
    # => Search Filter Comments
    feed = FeedItem.new
    
    if action.action_type == Action.types[:event_created]
      event = action.event
      subscriptions = SearchSubscription.matching_event(event)
      feed.feed_type = FeedItem.types[:event_created]
      feed.event_id = action.event_id
    elsif action.action_type == Action.types[:search_comment]
      #TODO action comments where reply to search comment)
      subscriptions = SearchSubscription.matching_search_comment(action.comment)
    end

    subscriptions.each do |subscription|
      #Add to the user subscription email. Note that this could send the same event twice for two different subscriptions, make sure to handle

      #Add to the users dashboard
      Feed.push(redis, subscription.user, feed) #TODO
    end unless subscriptions.blank?
  end
end