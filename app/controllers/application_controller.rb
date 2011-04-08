class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :nav_state
  before_filter :restricted

  def authenticate_user_and_redirect!
    store_request
    authenticate_user!
  end

  #Override to change the path taken after sign_in
  def after_sign_in_path_for(resource_or_scope)
    if session[:stored_request]
      return_path = session[:stored_request][:fullpath]
      #stored_method = session[:stored_request][:method]
      stored_controller = session[:stored_request][:params] [:controller]
      stored_action = session[:stored_request][:params][:action]

      #Add any controller/action specific logic here
      if stored_controller == 'events' && stored_action == 'create'
        if create_or_edit_event(session[:stored_request][:params], :create)
          return_path =  @event
        else
          return_path = new_event_path(@event)
          #TODO - This does not display the saved data or errors, but just shows an empty form
        end
      end

      #Clear the session
      clear_stored_request

      #redirect to the return_path
      return return_path
    else
      super
    end
  end

  
  protected

  def store_request
    session[:stored_request] = {:method => request.method, :fullpath => request.fullpath, :params => request.parameters}
  end

  def clear_stored_request
    session[:stored_request] = nil
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

    return @event.save
  end
end
