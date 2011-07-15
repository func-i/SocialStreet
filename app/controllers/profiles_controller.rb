# To change this template, choose Tools | Templates
# and open the template in the editor.

class ProfilesController < ApplicationController
  before_filter :store_current_path, :only => [:show, :edit]
  before_filter :authenticate_user!
  before_filter :require_user
  before_filter :require_permission, :only => [:edit, :update]


  def show
#    @actions = @user.actions.newest_first.all

    #@events = @user.rsvps.attending_or_maybe_attending.all.collect {|rsvp| rsvp.event if rsvp.event.upcoming? }.compact
    #    @events = @user.rsvp_events.

    @user_profile_facebook = @user.authentications.facebook.first

    @upcoming_events = Event.attended_by_user(@user).upcoming.order("starts_at")
    @upcoming_events_remaining = @upcoming_events.count - 3
    @upcoming_events = @upcoming_events.limit(3)


    @connected_rsvps = current_user.rsvps.attending_or_maybe_attending.also_attended_by(@user).order("rsvps.created_at DESC")
    @connected_rsvps_remaining = @connected_rsvps.count - 3
    @connected_rsvps = @connected_rsvps.limit(3)

    @connected_actions = current_user.actions.connected_with(@user).newest_first.uniq_by{|a| a.action_id || a.id }    
    @connected_actions_remaining = @connected_actions.count - 3
    @connected_actions = @connected_actions[0,3]

    @common_people = current_user.connections.common_with(@user)
    @common_people_remaining = @common_people.count - 24
    @common_people = @common_people.limit(24)


    @comment = Comment.new

    #Action List
    @actions = Action.for_user(@user).top_level.newest_first

    @per_page = 5
    @offset = ((params[:page] || 1).to_i * @per_page) - @per_page
    @total_count = @actions.count
    @num_pages = (@total_count.to_f / @per_page.to_f).ceil

    @actions = @actions.includes(:reference).limit(@per_page).offset(@offset)

    if request.xhr? && params[:page] # pagination request
      render :partial => 'new_page'
    end
  end
  
  def edit
    @authentications = @user.authentications
    @subscriptions = @user.search_subscriptions
    @events_where_administrator = Event.administered_by_user(current_user).upcoming.all
  end

  def update
    @user.attributes = params[:user]
    if @user.save
      #redirect_to edit_profile_path , :notice => "You have successfully updated your profile"
      redirect_to edit_profile_path
    else
      #redirect_to edit_profile_path, :notice => "Error updating your profile"
      redirect_to edit_profile_path
    end
  end

  def require_user
    @user = User.find params[:id]
    raise ActiveRecord::RecordNotFound unless @user.sign_in_count > 0
  end

  def require_permission
    raise ActiveRecord::RecordNotFound if !@user.editable_by?(current_user)
  end

end
