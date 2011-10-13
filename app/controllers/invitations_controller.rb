class InvitationsController < ApplicationController

  before_filter :load_event_and_rsvp

  # only support nested action that expects event and rsvp IDs
  # Note: It's actually allowing the creation of multiple invitations here
  def new
    if current_user.nil?
      render :nothing => true
      return
    end

    if current_user.fb_friends_imported?

      load_connections

      @event.action.user_list.each do |user|
        if user != current_user && current_user.invitations.for_event(@event).to_user(user).blank?
          @rsvp.invitations.build :event => @event, :user => current_user, :to_user => user
        end
      end unless @event.action.blank?

      @invitations = @rsvp.invitations

      render :partial => 'new_page' if request.xhr? && params[:page] # pagination request
    else
      redirect_to import_facebook_friends_connections_path(:return => load_modal_event_rsvp_invitation_path(@event, @rsvp))
    end

  end

  def load_modal
    puts "loading modal"
    if current_user.nil?
      render :nothing => true
      return
    end

    if current_user.fb_friends_imported?
      load_connections

      @event.action.user_list.each do |user|
        if user != current_user && current_user.invitations.for_event(@event).to_user(user).blank?
          @rsvp.invitations.build :event => @event, :user => current_user, :to_user => user
        end
      end unless @event.action.blank?

      @invitations = @rsvp.invitations
    else
      redirect_to import_facebook_friends_connections_path(:return => load_modal_event_rsvp_invitation_path(@event, @rsvp))
    end
  end

  def change
    if current_user.fb_friends_imported?
      load_connections

      @invitations = @rsvp.invitations

      render "new" if request.xhr?
    else
      redirect_to import_facebook_friends_connections_path(:return =>  change_event_rsvp_invitations_path(@event, @rsvp))
    end

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

    #Post to the user's wall if they have not unchecked the facebook checkbox
    if params[:facebook] == '1'
      if !@rsvp.posted_to_facebook
        if @event.photo?
          photo_url = @event.photo.thumb.url
        elsif !@event.event_types.blank? && et = @event.event_types.detect {|et| et.image_path? }
          photo_url = et.image_path
        else
          photo_url = 'images/event_types/streetmeet' + (rand(8) + 1).to_s + '.png'
        end

        @rsvp.user.post_to_facebook_wall(
          :picture => "http://www.socialstreet.com/#{photo_url}",
          :link => "http://www.socialstreet.com/events/#{@event.id}",
          :name => @event.title,
          :caption => "Brought to you by SocialStreet",
          :description => @event.name.blank? ? "" : @event.title_from_parameters(true),
          :message => "I'm attending this StreetMeet on SocialStreet!",
          :type => "link"
        )

        @rsvp.update_attribute("posted_to_facebook", true)
      end
    end

    redirect_to @event
  end

  protected

  def load_event_and_rsvp
    @event = Event.find params[:event_id].to_i
    @rsvp = @event.rsvps.find params[:rsvp_id].to_i
  end

  def load_connections

    puts "loading connections"

    ActiveRecord::Base.connection.execute('SET enable_nestloop TO off;')

    @per_page = 36
    @offset = ((params[:page] || 1).to_i * @per_page) - @per_page

    # => TODO: see if you can take that inline string notation out
    @users = User.select("users.id, users.first_name, users.last_name, users.sign_in_count, users.facebook_profile_picture_url, users.twitter_profile_picture_url").
      joins("LEFT OUTER JOIN connections ON users.id=connections.to_user_id AND connections.user_id=#{current_user.id}").
      where("users.id <> ?", current_user.id).
      where("(users.sign_in_count>0 OR connections.to_user_id IS NOT NULL)").
      #group("users.id, users.first_name, users.last_name, users.sign_in_count, users.facebook_profile_picture_url, users.twitter_profile_picture_url, connections.strength, connections.created_at").
    order("connections.strength DESC NULLS LAST, users.last_name ASC, connections.created_at ASC NULLS LAST")

    @users = @users.with_keywords(params[:user_search]) unless params[:user_search].blank?
    @total_count = User.find_by_sql("SELECT COUNT(*) as total_count FROM (#{@users.to_sql}) as tableA").first.total_count.to_i

    ## removed the limit on user load since pageless is currently not working
    #@users = @users.
      #limit(@per_page).
      #offset(@offset)

    @users = @users.all

    @num_pages_invitations = (@total_count.to_f / @per_page.to_f).ceil

    ActiveRecord::Base.connection.execute('SET enable_nestloop TO on;')
  end

  def create_invitation(event, rsvp, from_user, to_user, email = nil)
    invitation = from_user.invitations.create :event => event, :rsvp => rsvp, :to_user => to_user, :email => email
    invitation.save

    if to_user
      #Todo - handle when only have email
      Connection.connect_users_from_invitations(from_user, to_user)
    end

    if !to_user || !to_user.sign_in_count.zero?
      #Send email
      Resque.enqueue(Jobs::Email::EmailUserEventInvitation, invitation.id)
    elsif to_user
      if @event.photo?
        photo_url = @event.photo.thumb.url
      elsif !@event.event_types.blank? && et = @event.event_types.detect {|et| et.image_path? }
        photo_url = et.image_path
      else
        photo_url = 'images/event_types/streetmeet' + (rand(8) + 1).to_s + '.png'
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