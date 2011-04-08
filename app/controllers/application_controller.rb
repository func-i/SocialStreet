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
      stored_controller = session[:stored_request][:parameters] [:controller]
      stored_action = session[:stored_request][:parameters] [:action]

      #Add any controller/action specific logic here
      if stored_controller == 'events' && stored_action == 'create'
        #return_path = create_event session[:stored_request][:parameters]
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

end
