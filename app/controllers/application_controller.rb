class ApplicationController < ActionController::Base
  protect_from_forgery

  def ss_authenticate_user!
    authenticate_user!
  end

  def store_redirect(options = {})
    session[:stored_redirect] = Hash.new if !session[:stored_redirect]

    session[:stored_redirect][:controller] = options[:controller] if options[:controller]
    session[:stored_redirect][:action] = options[:action] if options[:action]
    session[:stored_redirect][:params] = options[:params].clone if options[:params]
  end
  
  def store_current_path
    session[:stored_current_path] = request.fullpath
  end

  def get_current_path
    return session[:stored_current_path] if session[:stored_current_path]
    return null;
  end

  def after_sign_in_path_for(resource_or_scope)
    if session[:stored_redirect]
      if session[:stored_redirect][:controller] == 'comments' && session[:stored_redirect][:action] == 'create'
        if create_comment(session[:stored_redirect][:params])
          return_path = get_current_path
        end
      end
    end

    return return_path if return_path
    raise 'Sorry, there was an error. We are doing our best to see that no one ever makes an error again'
  end

  def create_comment(event_id, comment_body)
    event = Event.find event_id
    if event
      @comment = Comment.new
      @comment.body = comment_body
      @comment.event = event
      @comment.user = current_user

      if @comment.save
        #TODO - email event admin
        #TODO - connect users (does this apply since to threading?)
        return true
      else
        return false
      end
    end
  end
