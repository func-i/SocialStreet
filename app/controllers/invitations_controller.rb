class InvitationsController < ApplicationController
  USERS_PER_PAGE = 50
  def load_connections
    page = (params[:page] || 1).to_i
    offset = (page - 1) * USERS_PER_PAGE

    if(current_user)
      @invited_user_connections = current_user.connections.includes(:to_user).order("connections.strength DESC NULLS LAST, users.last_name ASC")
      @invited_user_connections = @invited_user_connections.to_user_matches_keyword(params[:user_search]) unless params[:user_search].blank?

      @num_pages = (@invited_user_connections.count / USERS_PER_PAGE).ceil if 1 == page

      @invitation_user_connections = @invited_user_connections.limit(USERS_PER_PAGE).offset(offset).all
    end

  end

  #Create invitations
  def new
    @event = Event.find params[:event_id]
    
    (params[:invited_users] || []).each do |user_id|
      if user = User.find(user_id)
        create_invitation(@event, current_user, user)
      end
    end

    (params[:invited_emails] || []).each do |email|
      if user = User.find_by_email(email)
        create_invitation(@event, current_user, user)
      else
        create_invitation(@event, current_user, nil, email)
      end
    end

    if params[:post_to_facebook] == 'true'
      my_event_rsvp = @event.event_rsvps.where(:user_id => current_user).first
      if my_event_rsvp && my_event_rsvp.posted_to_facebook
        if current_user == @event.user
          Resque.enqueue_in(10.minutes, Jobs::Facebook::PostEventCreation, current_user.id, @event.id)
        else
          Resque.enqueue_in(10.minutes, Jobs::Facebook::PostEventAttending, current_user.id, @event.id)
        end

        my_event_rsvp.update_attribute(:posted_to_facebook => true)
      end
    end

    render :nothing => true
  end 

  protected

  def create_invitation(event, from_user, to_user, email = nil)
    return if to_user && event.event_rsvps.where(:user_id => to_user).count > 0

    invitation = event.event_rsvps.create :user => to_user, :invitor => from_user, :status => EventRsvp.statuses[:invited], :email => email
    invitation.save

    if (!to_user || !to_user.sign_in_count.zero?) && (email || to_user.email)
      Resque.enqueue(Jobs::Email::EmailUserEventInvitation, invitation.id)
    elsif to_user
      Resque.enqueue(Jobs::Facebook::PostEventInvitation, from_user.id, to_user.id, @event.id)
    end
  end
end