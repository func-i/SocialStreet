class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :nav_state
  before_filter :restricted

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

    #puts "STORING REDIRECT"
    #puts options.inspect
    #puts session[:stored_redirect].inspect
  end

  def clear_redirect
    #puts "CLEARING REDIRECT"
    session[:stored_redirect] = nil
  end

  #Override to change the path taken after sign_in
  def after_sign_in_path_for(resource_or_scope)
    if session[:stored_redirect]
      #User has stored a redirect path for use after authentication
      if session[:stored_redirect][:controller] == 'events' && session[:stored_redirect][:action] == 'create'
        if create_or_edit_event(session[:stored_redirect][:params], :create)
          return_path = [:new, @event, @event.rsvps.first, :invitation] # step2 - invite friends to new event - KV
        else
          session[:stored_params] = session[:stored_redirect][:params][:event]
          return_path = new_event_path
        end
      elsif session[:stored_redirect][:controller] == 'comments' && session[:stored_redirect][:action] == 'create'
        if create_comment(session[:stored_redirect][:params])
          return_path = session[:stored_current_path]
        else
          raise 'shit, what happened'
        end
      else
        return_path = session[:stored_current_path]
      end

      clear_redirect
      
      return return_path
    else
      super
    end
  end
  
  def restricted
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == "ssusername" && password == "sspassword"
    end if Rails.env.production?
  end

  def nav_state
    # overwritten by controllers
  end

  def create_or_edit_event(params, action)
    if action == :create
      #Create the event
      @event = Event.new
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

    @comment = Comment.new params[:comment]
    @comment.commentable = @commentable
    @comment.user = current_user

    if search_filters_present? 
      # Build the Searchable object for the Comment
      @comment.searchable = Searchable.new_from_params(params)
      # intentionally don't give this search filter a user_id since it was not intentionally/directly created by the user
    end

    if @comment.save
      Connection.connect_with_users_in_action_thread(@comment.user, @comment.action)
      return true
    end

    return false
  end

  def search_filters_present?
    params[:from_date] || params[:location] || params[:from_time]
  end
  
end
