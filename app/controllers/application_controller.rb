class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :nav_state
  before_filter :restricted
  #before_filter :prepare_create_event_event

  #  def authenticate_user_and_redirect!
  #    #User will be forced to sign-in when:
  #    # => Creating/Editing an Event (onSubmit)
  #    # => Updating or Creating an RSVP to an Event (onLoad)
  #    # => Commenting on an Event (onSubmit)
  #    # => Editing / Updating their profile (hidden, therefore fail)
  #
  #    store_request
  #    authenticate_user!
  #  end

  protected

  def store_current_path
    session[:stored_current_path] = request.fullpath
  end

  def stored_path
    session[:stored_current_path]
  end

  def store_redirect(options = {})
    session[:stored_redirect] = Hash.new if !session[:stored_redirect]
    
    session[:stored_redirect][:path] = options[:path] if options[:path]
    session[:stored_redirect][:controller] = options[:controller] if options[:controller]
    session[:stored_redirect][:action] = options[:action] if options[:action]
    session[:stored_redirect][:params] = options[:params].clone if options[:params]
    
    # Don't want the photo (temp image file) data being stored in session.
    # If we do that, it will result in "Can't dump File" exception - KV
    if session[:stored_redirect][:params] && session[:stored_redirect][:params][:event]
      session[:stored_redirect][:params][:event] = session[:stored_redirect][:params][:event].except(:photo)
    end
  end

  def clear_redirect
    session[:stored_redirect] = nil
  end

  #Override to change the path taken after sign_in
  def after_sign_in_path_for(resource_or_scope)
    if session[:stored_redirect]

      #User has stored a redirect path for use after authentication

      if session[:stored_redirect][:controller] == 'events' && session[:stored_redirect][:action] == 'create'

        #User was trying to create an event. Create it

        if create_or_edit_event(session[:stored_redirect][:params], :create)

          #Create was a success

          if current_user.fb_friends_imported?
            return_path = event_path(@event, :invite => true)
          else
            #TODO - What should this be?
            return_path = event_path(@event, :invite => true)
            #return_path = import_facebook_friends_connections_path(:return => new_event_rsvp_invitation_path(@event, @event.rsvps.first))
          end

        else

          #Create failed
          session[:stored_params] = session[:stored_redirect][:params][:event]

          if current_user.fb_friends_imported?
            #TODO - What should this be. Currently, doesn't load modal on error
            return_path = stored_path + "?&create_event=1"
            #return_path = new_event_path
          else
            #TODO - What should this be. Currently, doesn't load modal on error
            return_path = stored_path + "?&create_event=1"
            #return_path = import_facebook_friends_connections_path(:return => new_event_path)
          end
        end

      elsif session[:stored_redirect][:controller] == 'comments' && session[:stored_redirect][:action] == 'create'

        #User was trying to create a comment

        if create_comment(session[:stored_redirect][:params])

          return_path = session[:stored_current_path]

        else
          
          raise 'shit, what happened'

        end
      elsif session[:stored_redirect][:controller] == 'search_subscriptions' && session[:stored_redirect][:action] == 'create'

        if create_search_subscription(session[:stored_redirect][:params])
          return_path = :back
          puts "HI THERE"
        else
          #TODO - what should this be?
          return_path = session[:stored_current_path]
          puts "GOODBYE"
        end

      else
        puts "WHAT THE FUCK! HOW DID I END UP HERE"
      end

      clear_redirect
      
      return return_path
    else
      super
    end
  end
  
  def restricted
    #    authenticate_or_request_with_http_basic do |user_name, password|
    #      user_name == "ssusername" && password == "sspassword"
    #    end if Rails.env.staging?
  end

  def nav_state
    # overwritten by controllers
  end

  def prepare_create_event_event
    #    @event_for_create = Event.new
    #    @event_for_create.searchable ||= Searchable.new
    #    @event_for_create.searchable.location ||= Location.new
    #    @event_for_create.searchable.searchable_date_ranges.build({
    #        :starts_at => Time.zone.now.advance(:hours => 3).floor(15.minutes),
    #        :ends_at => Time.zone.now.advance(:hours => 6).floor(15.minutes)
    #      })
    #    #@event.action = @action - TODO - need to do this in javascript
    #
    #    if session[:stored_params]
    #      @event_for_create.attributes = session[:stored_params] # event params
    #      @event_for_create.valid?
    #      session[:stored_params] = nil
    #    end

    #@event_types_for_create ||= EventType.order('name').all
  end

  def create_search_subscription(params)
    @search_subscription = SearchSubscription.new_from_params(params[:q])
    @search_subscription.user = current_user
    @search_subscription.attributes = params[:search_subscription]

    return @search_subscription.save
  end

  def create_or_edit_event(params, action)
    if action == :create
      #Create the event
      @event = Event.new
      @event_for_create = @event
      @event.user = current_user if current_user # TODO: remove if statement when enforced.
    end
 
    @event.attributes = params[:event]       
    @event.location.user = current_user if @event.location
    
    if @event.save      
      Connection.connect_with_users_in_action_thread(@event.user, @event.action) if @event.action
      return true
    end

    return false
  end

  def create_comment(params)
    @commentable = Event.find params[:event_id].to_i if params[:event_id]
    @commentable = Action.find params[:action_id].to_i if params[:action_id]
    @commentable = User.find params[:profile_id].to_i if params[:profile_id]

    @comment = Comment.new params[:comment]
    @comment.commentable = @commentable
    @comment.user = current_user

    if search_filters_present?(params)
      # Build the Searchable object for the Comment
      params[:keywords] = params[:comment_keywords]
      params[:map_center] = params[:comment_map_center]
      params[:map_location] = params[:comment_map_location]

      puts "CREATING A NEW SEARCHABLE"
      @comment.searchable = Searchable.new_from_params(params)
      puts @comment.inspect
      # intentionally don't give this search filter a user_id since it was not intentionally/directly created by the user
    elsif @commentable.respond_to?(:searchable) && @commentable.searchable
    #elsif @commentable.searchable
      @comment.searchable = @commentable.searchable
    end

    puts "SAVING COMMENT"
    if @comment.save
      @comment.reload

      Connection.connect_with_users_in_action_thread(@comment.user, @comment.action)
      return true
    end

    return false
  end

  def search_filters_present?(params)
    params[:comment_keywords] || params[:comment_map_center]
  end
  
end
