# RSVPs for the currently logged in user, for a given Event (by :event_id)

class AdministratorsController < ApplicationController
  before_filter :store_current_path, :only => [:new, :edit]
  before_filter :ss_authenticate_user!
  before_filter :require_event
  before_filter :require_permission, :only => [:edit, :update]

  def new
    if current_user.fb_friends_imported?
      load_connections()
      @rsvps = @event.rsvps.all
      #@connections = current_user.connections.most_relevant_first.all
      @administrator_rsvps = @rsvps.select &:administrator?
    
      render :partial => 'new_page' if request.xhr? && params[:page] # pagination request
    else
      redirect_to import_facebook_friends_connections_path(:return => new_event_administrator_path(@event))
    end

  end

  def load_modal
    if current_user.fb_friends_imported?
      load_connections
      @rsvps = @event.rsvps.all
      @connections = current_user.connections.most_relevant_first.all
      @administrator_rsvps = @rsvps.select &:administrator?
    else
      redirect_to import_facebook_friends_connections_path(:return => load_modal_event_administrator_path(@event))
    end
  end

  def create

    num_added, num_removed = 0,0

    params[:user_ids].each do |user_id|
      if user = User.find_by_id(user_id)
        rsvp = @event.rsvps.where(:user_id => user_id).first
        if rsvp && !rsvp.administrator?
          rsvp.administrator = true
          rsvp.save
          num_added += 1
        elsif rsvp.blank?
          rsvp = @event.rsvps.create :user => user, :administrator => true, :status => Rsvp.statuses[:maybe_attending]
          num_added += 1
        end
      end
    end unless params[:user_ids].blank?

    @event.rsvps.administrators.all.each do |rsvp|
      if !(params[:user_ids] || []).include? rsvp.user_id.to_s
        rsvp.administrator = false
        rsvp.save
        num_removed += 1
      end
    end

    #redirect_to @event, :notice => "Added #{num_added} and removed #{num_removed} Administrators."
    redirect_to @event
  end
  
  protected

  def load_connections

    # => TODO: Add search user search functionality to endless pagination.

    @per_page = 36
    @offset = ((params[:page] || 1).to_i * @per_page) - @per_page

    # => TODO: see if you can take that inline string notation out
    @users = User.select("users.id, users.first_name, users.last_name, users.facebook_profile_picture_url, users.twitter_profile_picture_url, rsvps.administrator").
      joins("LEFT OUTER JOIN connections ON users.id=connections.to_user_id AND connections.user_id=#{current_user.id}").
      joins("LEFT OUTER JOIN rsvps ON rsvps.user_id = users.id AND rsvps.event_id = #{@event.id}").
      where("users.id <> ?", current_user.id).
      where("(users.sign_in_count>0 OR connections.to_user_id IS NOT NULL)").
      group("users.id, users.first_name, users.last_name, users.facebook_profile_picture_url, users.twitter_profile_picture_url, connections.strength, connections.created_at, rsvps.administrator").
      order("connections.strength DESC NULLS LAST, connections.created_at ASC NULLS LAST")

    @users = @users.with_keywords(params[:user_search]) unless params[:user_search].blank?
    @total_count = User.find_by_sql("SELECT COUNT(*) as total_count FROM (#{@users.to_sql}) as tableA").first.total_count.to_i

    @users = @users.
      limit(@per_page).
      offset(@offset)

    @num_pages_administrators = (@total_count.to_f / @per_page.to_f).ceil

  end


  def require_event
    @event = Event.find params[:event_id].to_i
  end

  def require_permission
    raise ActiveRecord::RecordNotFound if @event.user != current_user
  end
end
