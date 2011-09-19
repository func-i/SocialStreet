class InvitationsController < ApplicationController
  #Search for invitations
  def search
    @invited_user_connections = current_user.connections.includes(:to_user)
    @invited_user_connections = @invited_user_connections.to_user_matches_keyword(params[:user_search]) unless params[:user_search].blank?
    @invited_user_connections = @invited_user_connections.all
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

    render :nothing => true
  end

  protected

  def create_invitation(event, from_user, to_user, email = nil)
    return if to_user && event.event_rsvps.where(:user_id => to_user).count > 0

    invitation = event.event_rsvps.create :user => to_user, :invitor => from_user, :status => EventRsvp.statuses[:invited], :email => email
    invitation.save

    if (!to_user || !to_user.sign_in_count.zero?) && (email || to_user.email)
      #Send email
      Resque.enqueue(Jobs::Email::EmailUserEventInvitation, invitation.id)
    elsif to_user
      if !@event.event_types.empty? && et = @event.event_types.detect {|et| et.image_path? }
        et.image_path
      else
        'event_types/streetmeet' + (rand(8) + 1).to_s + '.png'
      end
      
      options = {
        :picture => "http://www.socialstreet.com/#{photo_url}",
        :link => "http://www.socialstreet.com/events/#{@event.id}",
        :name => @event.title,
        :caption => "Brought to you by SocialStreet",
        :description => @event.name.blank? ? "" : @event.title_from_parameters(true),
        :message => "I want to invite you to join this StreetMeet on SocialStreet!",
        :type => "link"
      }

      Resque.enqueue_in(10.minutes, Jobs::Facebook::PostToFriendsFbWall, from_user.id, to_user.id, options)
    end
  end
end