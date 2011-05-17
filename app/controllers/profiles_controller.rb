# To change this template, choose Tools | Templates
# and open the template in the editor.

class ProfilesController < ApplicationController
  before_filter :store_current_path, :only => [:show, :edit]
  before_filter :authenticate_user!
  before_filter :require_user
  before_filter :require_permission, :only => [:edit, :update]


  def show
    @actions = Action.for_user(@user).newest_first.top_level.all
#    @actions = @user.actions.newest_first.all

    #@events = @user.rsvps.attending_or_maybe_attending.all.collect {|rsvp| rsvp.event if rsvp.event.upcoming? }.compact
    #    @events = @user.rsvp_events.

    @events = Event.attended_by_user(@user).upcoming.order("starts_at").limit(5)

    @user_profile_facebook = @user.authentications.facebook.first

    @connected_rsvps = current_user.rsvps.attending_or_maybe_attending.also_attended_by(@user).order("rsvps.created_at DESC")

    @connected_actions = current_user.actions.connected_with(@user).newest_first.limit(10)

    @common_connections = current_user.connections.common_with_ordered_by_strength(@user).limit(10)

    @comment = Comment.new
  end
  
  def edit
    @authentications = @user.authentications
    @subscriptions = @user.search_subscriptions
    @events_where_administrator = Event.administered_by_user(current_user).upcoming.all
  end

  def update
    @user.attributes = params[:user]
    if @user.save
      redirect_to edit_profile_path , :notice => "You have successfully updated your profile"
    else
      redirect_to edit_profile_path, :notice => "Error updating your profile"
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
