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

  def clear_redirect
    session[:stored_redirect] = nil
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

        event_id = session[:stored_redirect][:params][:event_id].to_i
        body = session[:stored_redirect][:params][:comment][:body]
        if create_comment(event_id, body)
          return_path = get_current_path
        end
      elsif session[:stored_redirect][:controller] == 'events' && session[:stored_redirect][:action] == 'create'

        #User was trying to create an event. Create it

        if create_or_edit_event(session[:stored_redirect][:params], :create)

          #Create was a success
          return_path = event_path(@event, :invite => true)
        else

          #Create failed
          session[:stored_params] = session[:stored_redirect][:params][:event]

          #TODO - What should this be. Currently, doesn't load modal on error
          return_path = stored_path + "?&create_event=1"
        end

      elsif session[:stored_redirect][:controller] == 'event_rsvps' && session[:stored_redirect][:action] == 'new'

        if attending_event_rsvp(session[:stored_redirect][:params][:event_id].to_i)
          return_path = event_path(@event, :invite => true)
        end

      end

      return return_path if return_path

      current_path = get_current_path
      return current_path if current_path
    end

    super

    #raise 'Sorry, there was an error. We are doing our best to see that no one ever makes an error again'
  end

  def create_or_edit_event(params, action)
    if action == :create
      #Create the event
      @event = Event.new()
      @event.user = current_user if current_user # TODO: remove if statement when enforced.
    end

    @event.attributes = params[:event]
    #@event.location.user = current_user if @event.location

    if @event.save
      # Connection.connect_with_users_in_action_thread(@event.user, @event.action) if @event.action
      return true
    end

    return false
  end

  def create_comment(event_id, comment_body)
    event = Event.find event_id
    if event
      @comment = Comment.new
      @comment.body = comment_body
      @comment.event = event
      @comment.user = current_user

      if @comment.save
        Resque.enqueue(Jobs::Email::EmailEventAdminForAction, @comment.id, event.id)
        #TODO - email event admin
        #TODO - connect users (does this apply since to threading?)
        return true
      else
        return false
      end
    end
  end

  def attending_event_rsvp(event_id)
    return false unless current_user

    @event = Event.find event_id
    rsvp = @event.event_rsvps.by_user(current_user).first if current_user

    if !rsvp
      rsvp = @event.event_rsvps.build
      rsvp.user = current_user
    end

    rsvp.status = EventRsvp.statuses[:attending]

    if(rsvp.save)
      return true
    else
      return false
    end
  end
end
