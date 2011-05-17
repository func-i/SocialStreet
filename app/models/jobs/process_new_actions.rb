# Create the initial connections via facebook
class Jobs::CleanupDashboardSet
@queue = :connections

  CONNECTION_RANK_LIMIT = 30

  def self.perform(action_id)
    action = Action.find(action_id)

    #Add action to any user who has subscribed to it
    handle_subscriptions(action)

    #Add to any user who was part of the action chain
    handle_action_chain(action)

    #Add to any user who is connected to the actor
    handle_connections(action)

  end

  def handle_connections(action)
    #Handle:
    # => Event Creation
    # => RSVP
    # => Comments (event, action/replies, profile and search filter)
    connections = Connection.to_user(action.user).ranked_less_or_eq(CONNECTION_RANK_LIMIT).all
    connections.each do |connection|
      #add to dashboard
      Feed.push(redis, connection.user, nil) #TODO
    end
  end

  def handle_action_chain(action)

  end

  def handle_subscriptions(action)
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