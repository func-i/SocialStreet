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

  def store_current_path
    store_redirect(:path => request.fullpath)
  end

  def store_redirect(options = {})
    session[:stored_redirect] = Hash.new if !session[:stored_redirect]
    
    session[:stored_redirect][:path] = options[:path] if options[:path]
    session[:stored_redirect][:controller] = options[:controller] if options[:controller]
    session[:stored_redirect][:action] = options[:action] if options[:action]
    session[:stored_redirect][:params] = options[:params] if options[:params]

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
          return_path = @event
        else
          session[:saved_created_event] = @event
          return_path = new_event_path
          # TODO - This should render the create event page with the already defined event information inside the form, but currently shows empty form
        end
      elsif session[:stored_redirect][:controller] == 'comments' && session[:stored_redirect][:action] == 'create'
        if create_comment(session[:stored_redirect][:params])
          return_path = session[:stored_redirect][:path]
        else
          raise 'shit, what happened'
        end
      else
        return_path = session[:stored_redirect][:path]
      end

      clear_redirect
      
      return return_path
    else
      super
    end
  end
  
  protected

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

    return @event.save
  end

  def create_comment(params)
    @commentable = Event.find params[:event_id].to_i if params[:event_id]
    @commentable = Activity.find params[:activity_id].to_i if params[:activity_id]

    @comment = @commentable.comments.build params[:comment]
    @comment.user = current_user

    return @comment.save
  end
end
