class EventsController < ApplicationController

  before_filter :store_current_path, :only => [:show, :new, :edit]
  before_filter :store_event_create, :only => [:create, :update]
  before_filter :authenticate_user!, :only => [:create, :edit, :update]
  before_filter :require_permission, :only => [:edit, :update]
  before_filter :load_action, :only => [:new] # for event created through activity stream

  # EVENT DETAIL PAGE
  def show
    @event = Event.find params[:id]
    @rsvp = @event.rsvps.by_user(current_user).first if current_user
    @actions = @event.actions.newest_first.all # TODO: paginate @actions here (page = 1)
    @comment = @event.comments.build
  end

  #EVENT CREATE/EDIT PAGES
  def new
    @event = Event.new
    @event.searchable ||= Searchable.new
    @event.searchable.location ||= Location.new
    @event.searchable.searchable_date_ranges.build
    @event.searchable.searchable_event_types.build
    @event.action = @action # nil if no @action (which is desired)
    if session[:stored_params]
      @event.attributes = session[:stored_params] # event params
      @event.valid?
      session[:stored_params] = nil
    end
    
    prepare_for_form
  end

  def create
    if create_or_edit_event(params, :create)
      redirect_to [:new, @event, @event.rsvps.first, :invitation], :notice => "Your event is created. You can invite some of your friends below."
    else
      prepare_for_form
      render :new
    end
  end

  def edit
    prepare_for_form
  end

  def update
    if create_or_edit_event(params, :edit)
      redirect_to @event
    else
      prepare_for_form
      render :edit
    end
  end

  def destroy
    @event = Event.find params[:id]
    if @event.destroy
      #TODO - send emails to everyone
      redirect_to :root
    else
      raise "WHAT THE F***"
    end
  end


  protected

  def store_event_create
    store_redirect(:controller => 'events', :action => 'create', :params => params)
  end

  def require_permission
    @event = Event.find params[:id]

    raise ActiveRecord::RecordNotFound if !@event.editable_by?(current_user)
  end

  def load_event_types
    @event_types ||= EventType.order('name').all
  end

  def load_action
    # TODO: Perhaps creation through action should be a separate controller/resource:  "/actions/x/events/new"
    @action = Action.find_by_id params[:action_id].to_i if params[:action_id]
  end

  def nav_state
    if params[:action] == 'create' || params[:action] == 'new'
      @on_create_event = true
    end
  end

  def prepare_for_form
    load_event_types
  end

end
