class ApplicationController < ActionController::Base
  protect_from_forgery

  layout 'application'

  before_filter :redirect_mobile
  before_filter :check_browser

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
    return nil;
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

      elsif session[:stored_redirect][:controller] == 'profiles' && session[:stored_redirect][:action] == 'add_group'

        if add_group_to_profile(session[:stored_redirect][:params][:group_id], session[:stored_redirect][:params][:user_id],session[:stored_redirect][:params][:group_code])
          return_path = get_current_path
        end
      elsif session[:stored_redirect][:controller] == 'chat_rooms'
        return_path = root_path(:chat_room_id => session[:stored_redirect][:params][:chat_room_id])
      end

      return return_path if return_path
    end

    current_path = get_current_path
    return current_path if current_path

    super

    #raise 'Sorry, there was an error. We are doing our best to see that no one ever makes an error again'
  end

  def add_group_to_profile(group_id, user_id, group_code)
    group = Group.find group_id
    if group.join_code_description.blank?
      user_group = UserGroup.where(:group_id => group_id, :user_id => user_id).limit(1)
      if user_group.length <= 0
        user_group = UserGroup.new(:user_id  => user_id, :group_id => group_id, :applied => false)
      elsif user_group.applied
        user_group.applied = false
        user_group.save
      end

      return nil
    else
      #Validate group code
      if group.is_code_valid(group_code)
        #Check user_group table for group_id & group_code and user_id is empty
        user_group = UserGroup.where(:group_id => group_id, :join_code => group_code).limit(1).first
        user_group.user = user_id
        user_group.applied = false
        user_group.save

        return true
      else
        #throw error
        return false
      end
    end
  end

  def create_or_edit_event(params, action)
    if action == :create
      #Create the event
      @event = Event.new()
      @event.user = current_user if current_user
    elsif action == :edit
      
      @event.event_keywords.each do |keyword|
        keyword.destroy
      end
    end

    @event.attributes = params[:event]

    #Groups
    @event.private = true
    @event.event_groups.each do |e_g|
      e_g.destroy
    end

    params[:group].each do |groupID, permissionLevel|
      e_g = @event.event_groups.build
      e_g.can_view = permissionLevel.to_i >= 1
      e_g.can_attend = permissionLevel.to_i >= 2

      if groupID.eql?('public')
        e_g.group_id = nil
        @event.private = false if e_g.can_view
      else
        e_g.group_id = groupID
      end
    end

    if @event.save
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

  def attending_event_rsvp(event_id, status = nil)
    return -1 unless current_user #error

    @event = Event.find event_id

    unless @event.can_attend?(current_user) 
      return 1 #Show groups
    end

    rsvp = @event.event_rsvps.by_user(current_user).first if current_user

    if !rsvp
      rsvp = @event.event_rsvps.build
      rsvp.user = current_user
    end

    rsvp.status = status ? EventRsvp.statuses[status.to_sym] : EventRsvp.statuses[:attending]

    if rsvp.save
      return 2 #Success
    else
      return -1#error
    end
  end

  protected

  def check_browser    
    redirect_to invalid_browser_path if request.env['HTTP_USER_AGENT'] =~ /MSIE 6.0|MSIE 7.0/ && !mobile_device?
  end

  private
  def mobile_device?
    if request.user_agent =~ /iPhone|webOS|iPod|Android|BlackBerry|Windows Phone|^iPad/
      return true
    end
  end
  helper_method :mobile_device?

  def redirect_mobile
    if mobile_device? && nil == (request.fullpath =~ /^\/m($|\/|\?|#)/)
      redirect_to "/m" + request.fullpath
    end
  end
end
