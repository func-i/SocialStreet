class EventsController < ApplicationController
  before_filter :store_current_path, :only => [:show]
  before_filter :store_create_request, :only => [:create]
  before_filter :ss_authenticate_user!, :only => [:create, :edit, :update, :destroy, :post_to_facebook]
 
  def show
    @event = Event.find params[:id]
    prepare_for_show
  end

  def new
    @event_types = EventType.order('name').all
    @event = Event.new
    @location = @event.build_location
  end

  def create 
    if create_or_edit_event(params, :create)
      @event.reload
      prepare_for_show
      #render :file => "events/show.js.erb"
      redirect_to @event
      #render :update do |page|
        #page.redirect_to @event
      #end
    end
  end

  protected

  def store_create_request
    store_redirect(:controller => 'events', :action => 'create', :params => params)
  end

  def prepare_for_show
    @comments = @event.comments.order('created_at DESC').all
    @comment = @event.comments.build

    @invitation_user_connections = current_user.connections.includes(:to_user).order("connections.strength DESC NULLS LAST, users.last_name ASC").limit(50).all if current_user
  end

end