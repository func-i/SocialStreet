class InvitationsController < ApplicationController

  before_filter :load_event_and_rsvp

  # only support nested action that expects event and rsvp IDs
  # Note: It's actually allowing the creation of multiple invitations here
  def new
    load_connections

    @event.action.user_list.each do |user|
      if user != current_user && current_user.invitations.for_event(@event).to_user(user).blank?
        @rsvp.invitations.build :event => @event, :user => current_user, :to_user => user
      end
    end unless @event.action.blank?
    
    @invitations = @rsvp.invitations
    
    render :partial => 'user_results' if request.xhr? && params[:page] # pagination request

  end

  def change
    load_connections

    @invitations = @rsvp.invitations

    render "new" if request.xhr?

  end

  # Note: It's actually creating multiple invitations here
  def create
    params[:emails].each do |email|
      if user = User.find_by_email(email)
        create_invitation(@event, @rsvp, current_user, user)
      else
        create_invitation(@event, @rsvp, current_user, nil, email)
      end
    end unless params[:emails].blank?

    params[:user_ids].each do |user_id|
      if user = User.find_by_id(user_id)
        create_invitation(@event, @rsvp, current_user, user)
      end
    end unless params[:user_ids].blank?

    num_invited = (params[:user_ids] || []).size + (params[:emails] || []).size
    # TODO: Handle validation issues with non-unique invitations (maybe?)
    redirect_to @event, :notice => "You've invited #{num_invited} of your friends to this event. [[Link to modify invitations]]"
  end

  protected

  def load_event_and_rsvp
    @event = Event.find params[:event_id].to_i
    @rsvp = @event.rsvps.find params[:rsvp_id].to_i
  end

  def load_connections

    # => TODO: Add search user search functionality to endless pagination.

    @per_page = 10
    @offset = ((params[:page] || 1).to_i * @per_page) - @per_page
    
    # => TODO: see if you can take that inline string notation out
    @users = User.select("users.id").
      joins("LEFT OUTER JOIN connections ON users.id=connections.to_user_id AND connections.user_id=#{current_user.id}").
      where("users.id <> ?", current_user.id).
      where("(users.sign_in_count>0 OR connections.to_user_id IS NOT NULL)").
      group("users.id")      

    @users = @users.with_keywords(params[:user_search]) unless params[:user_search].blank?
    @total_count = @users.count.size
    
    @users = @users.
      select("users.first_name, users.last_name, users.facebook_profile_picture_url, users.twitter_profile_picture_url, COALESCE(MAX(connections.strength), 0) as conn_str, COALESCE(MAX(connections.created_at),'1900-01-01') as conn_date").
      group("users.first_name, users.last_name, users.facebook_profile_picture_url, users.twitter_profile_picture_url").
      order("conn_str DESC, conn_date ASC").
      limit(@per_page).
      offset(@offset)
       
    @num_pages = (@total_count.to_f / @per_page.to_f).ceil
    
  end

  def create_invitation(event, rsvp, from_user, to_user, email = nil)
    from_user.invitations.create :event => event, :rsvp => rsvp, :to_user => to_user, :email => email

    if to_user
      #Todo - handle when only have email
      Connection.connect_users_from_invitations(from_user, to_user)
    end
  end

end