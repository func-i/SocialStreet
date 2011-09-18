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
    @event = Event.new params[:event]
    if create_or_edit_event(params, :create)
      prepare_for_show
      render :file => "events/show.js.erb"
    end
  end

  protected

  def store_create_request
    store_redirect(:controller => 'events', :action => 'create', :params => params)
  end

  def prepare_for_show
    @comments = @event.comments.order('created_at DESC').all
    @comment = @event.comments.build
  end

end