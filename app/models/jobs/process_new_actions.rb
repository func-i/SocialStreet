# Create the initial connections via facebook
class Jobs::ProcessNewActions
@queue = :connections

  CONNECTION_RANK_LIMIT_EVENT_CREATE = 40
  CONNECTION_RANK_LIMIT_EVENT_RSVP = 30
  CONNECTION_RANK_LIMIT_COMMENT = 20

  def self.perform(action_id)
    an_action = Action.find(action_id)

    #Add action to any user who has subscribed to it
    #handle_subscriptions(an_action)

    #Add to any user who was part of the action chain
    handle_action_chain(an_action)

    #Add to any user who is connected to the actor
    handle_connections(an_action)

  end

  def self.handle_connections(an_action)
    #Handle:
    # => Event Creation
    # => RSVP
    # => Comments (event, action/replies, profile and search filter)
    feed = FeedItem.new
    feed.inserted_because = FeedItem.reasons[:connection]
    
    if an_action.action_type == Action.types[:event_created]
      #Event Create - set event id
      feed.feed_type = FeedItem.types[:event_created]
      feed.event_id = an_action.event_id

      connections = Connection.to_user(an_action.user).ranked_less_or_eq(CONNECTION_RANK_LIMIT_EVENT_CREATE)

    elsif an_action.action_type == Action.types[:event_rsvp_attending]
      return false if an_action.user_id == an_action.event.user_id #So not to insert both rsvp and event create

      #RSVP - set event id
      feed.feed_type = FeedItem.types[:event_rsvp]
      feed.event_id = an_action.event_id

      connections = Connection.to_user(an_action.user).ranked_less_or_eq(CONNECTION_RANK_LIMIT_EVENT_RSVP)
    else
      #Comments - set base action_id
      feed.feed_type = FeedItem.types[:comment]
      feed.action_id = an_action.action ? an_action.action.id : an_action.id

      connections = Connection.to_user(an_action.user).ranked_less_or_eq(CONNECTION_RANK_LIMIT_COMMENT)
    end
      
    
    
    redis = Redis.new

    connections.all.each do |connection|
      #add to dashboard
      puts connection.inspect
      Feed.push(redis, connection.user, feed)
    end

    redis.quit
  end

  def self.handle_action_chain(an_action)
    #Handle:
    # => comments on actions (the base action can appear twice in some peoples dashboards through connections, fixme)
    # => events to action threads (will appear twice in some peoples dashboards through connections, fixme)
    return false if an_action.action.blank?

    feed = FeedItem.new
    feed.inserted_because = FeedItem.reasons[:participated]
    feed.feed_type = FeedItem.types[:comment]
    feed.action_id = an_action.action.id
    
    action_list = Action.threaded_with(an_action)

    redis = Redis.new

    action_list.all.each do |action|
      if action.user.id != an_action.user.id
        #add to dashboard
        Feed.push(redis, action.user, feed)

        #add to email
        #TODO
      end
    end

    redis.quit
  end

  def self.handle_subscriptions(action)
    #Actions that are delivered in subscriptions are:
    # => Event Creation
    # => Event Edit (not yet supported)
    # => Search Filter Comments

    if(action.action_type == Action.types[:event_created])
      event = action.event

      #type
      types = event.event_type

      #date
      start_date = event.starts_at
      end_date = event.finishes_at

      #time
      start_time = nil #TODO
      end_time = nil #TODO

      #location
      location_lat = event.latitude
      location_long = event.longitude
    elsif(action.action_type == Action.types[:search_comment]) #TODO action comments where reply to search comment)
      #TODO
    end

    @subscriptions = Searchable.with_only_subscriptions

    #types
    @subscriptions = @subscriptions.with_event_types(types)

    #date
    #TODO-Replace nil with days extract from event
    @subscriptions = @subscriptions.on_days_or_in_date_range(nil, event.starts_at, event.finishes_at)

    #Time
    #TODO
    @subscriptions = @subscriptions.at_or_after_time_of_day()
    @subscriptions = @subscriptions.at_or_before_time_of_day()

    #TODO - Location
    @subscriptions = @subscriptions

    @subscriptions.all.each do |subscription|
      #Add to the user subscription email. Note that this could send the same event twice for two different subscriptions, make sure to handle

      #Add to the users dashboard
      Feed.push(redis.new, subscription.user, nil) #TODO
    end
  end
end