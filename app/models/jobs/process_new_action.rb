# Create the initial connections via facebook
class Jobs::ProcessNewAction

  @queue = :actions

  CONNECTION_RANK_LIMIT_EVENT_CREATE = 40
  CONNECTION_RANK_LIMIT_EVENT_RSVP = 30
  CONNECTION_RANK_LIMIT_COMMENT = 20

  def self.perform(action_id)
    
    action = Action.find_by_id(action_id)
    # so we don't send instant emails multiple times to the same user for this action, b/c that would be bad ...
    @users_emailed = {}

    unless action
      sleep 2
      action = Action.find(action_id)
    end
    redis = Redis.new
    
    #Add to any user who was part of the action chain
    handle_action_chain(redis, action)

    #Add to any user who is connected to the actor
    handle_connections(redis, action)

    #Add action to any user who has subscribed to it
    handle_subscriptions(redis, action)

    #Add to default dashboard
    handle_default_dashboard(redis, action)


    redis.quit
  end

  def self.handle_connections(redis, action)
    #Handle:
    # => Event Creation
    # => RSVP
    # => Comments (event, action/replies, profile and search filter)
    unless action.action_type == Action.types[:event_rsvp_attending] && action.user == action.event.user # if its the owner of the event, no need to log it
      connections = Connection.to_user(action.user).ranked_less_or_eq(CONNECTION_RANK_LIMIT_EVENT_CREATE)
    end

    connections.all.each do |connection|
      #ADD TO DASHBOARD. CREATE RECORD IF NOT ALREADY THERE. ELSE UPDATE WITH NEW INDEX ACTION
      feed_item = Feed.where(:user_id => connection.user, :head_action_id => action.action || action).first

      if(nil == feed_item)
        feed_item = Feed.new(:user => connection.user, :head_action => action.action || action, :index_action => action, :reason => Feed.reasons[:connection])
      else
        feed_item.index_action = action;
        feed_item.reason = Feed.reasons[:connection]
      end
      feed_item.save

      Feed.push(redis, connection.user, feed_item)
    end unless connections.blank?

  end

  def self.handle_action_chain(redis, action)
    #Handle:
    # => comments on actions (the base action can appear twice in some peoples dashboards, fixme)
    # => events to action treads (will appear twice in some peoples dashboards, fixme)
    return false if action.action.blank?
    
    action_list = Action.threaded_with(action)

    action_list.all.each do |a|
      #add to dashboard
      if a.user.id != action.user.id
        # add to dashboard / news feed
        feed_item = Feed.where(:user_id => a.user, :head_action_id => action.action || action).first

        if(nil == feed_item)
          feed_item = Feed.new(:user => a.user, :head_action => action.action || action, :index_action => action, :reason => Feed.reasons[:action_chain])
        else
          feed_item.index_action = action;
          feed_item.reason = Feed.reasons[:action_chain]
        end
        feed_item.save

        Feed.push(redis, a.user, feed_item)

        # email notice to user
        # TODO: here we should perhaps check their profile settings to see if they want to be notified? - KV
        unless @users_emailed[a.user_id.to_s]
          Resque.enqueue(Jobs::EmailUserForActionChain, action.action.id, action.id, a.user.id)
          @users_emailed[a.user_id.to_s] = true
        end
      end
    end
  end

  def self.handle_default_dashboard(redis, action)
    if !(
        action.action_type == Action.types[:event_created] ||
        action.action_type == Action.types[:search_comment] ||
        (action.action_type == Action.types[:action_comment] && action.action.action_type == Action.types[:search_comment])
    )
      return
    end

    default_user = User.where(:username => "default_socialstreet_user").first;
    if !default_user
      default_user = User.new(:username => "default_socialstreet_user");
    end

    feed_item = Feed.where(:user_id => default_user, :head_action_id => action.action || action).first
    if(nil == feed_item)
      feed_item = Feed.new(:user => default_user, :head_action => action.action || action, :reason => Feed.reasons[:subscription])
      feed_item.save
    end
    Feed.push(redis, default_user, feed_item)

  end

  def self.handle_subscriptions(redis, action)
    #Actions that are delivered in subscriptions are:
    # => Event Creation
    # => Search Filter Comments

    # GET SUBSCRIPTIONS TO THIS ACTION
    puts "in handle subscriptions"
    if action.action_type == Action.types[:event_created]
      subscriptions = SearchSubscription.matching_event(action.event)
      puts "in create subscriptions"
      puts subscriptions.inspect
      
    elsif action.action_type == Action.types[:search_comment] ||
        (action.action_type == Action.types[:action_comment] && action.action.action_type == Action.types[:search_comment])

      subscriptions = SearchSubscription.matching_search_comment(action.reference) # reference is the Comment instance
      puts "in search comments"
      puts subscriptions.inspect
    end

    return if subscriptions.blank?

    # ADD TO NEWS STREAM / EMAIL (NO UNIQUENESS REQUIRED) FOR EACH SUBSCRIPTION
    subscriptions.each do |subscription|
      if subscription.user_id != action.user_id
        puts subscription.inspect

        #SEND SUBSCRIBERS EMAIL
        if subscription.immediate?
          user_id = subscription.user_id.to_s

          unless @users_emailed[user_id]
            Resque.enqueue(Jobs::EmailUserForSubscription, subscription.id, action.id)
            @users_emailed[user_id] = true
          end

        elsif subscription.not_immediate?

          action_id = action.action.try(:id) || action.id
          redis.zadd "digest_actions:#{subscription.id}", "#{Time.now.to_i}", action_id.to_s
          puts "in not immediate"
        end

        #ADD TO DASHBOARD. CREATE RECORD IF NOT ALREADY THERE FROM A CONNECTION
        feed_item = Feed.where(:user_id => subscription.user, :head_action_id => action.action || action).first
        if(nil == feed_item)
          feed_item = Feed.new(:user => subscription.user, :head_action => action.action || action, :reason => Feed.reasons[:subscription])
          feed_item.save
        end
        Feed.push(redis, subscription.user, feed_item)

      end
    end
  end
end