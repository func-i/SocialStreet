class EventsController < ApplicationController
  before_filter :store_current_path, :only => [:show]
  before_filter :store_create_request, :only => [:create]
  before_filter :ss_authenticate_user!, :only => [:create, :edit, :update, :destroy, :post_to_facebook]
 
  def show
    @event = Event.find params[:id]

    @page_title = "StreetMeet - #{@event.title}"

    prepare_for_show

    if request.xhr?
      render "shared/ajax_load.js", :locals => {:file_name_var => 'events/show.html.erb'}
    end
  end

  def new
    @page_title = "Plan StreetMeet"

    @event_types = EventType.order('name').all
    @event = Event.new

    @event.start_date = Time.now.advance(:hours => 3).floor(15.minutes)
    @event.end_date = Time.now.advance(:hours => 6).floor(15.minutes)
    
    @location = @event.build_location

    if request.xhr?
      render "shared/ajax_load.js", :locals => {:file_name_var => 'events/new.html.erb'}
    end
  end

  def create 
    if create_or_edit_event(params, :create)
      @event.reload
      prepare_for_show

      if request.xhr?
        render :update do |page|
          page.redirect_to event_path(@event, :invite => true)
        end
      else
        redirect_to event_path(@event, :invite => true)
      end
      
    end
  end

  def edit
    @event = Event.find params[:id]

    @page_title = "Edit StreetMeet - #{@event.title}"    

    @event_types = EventType.order('name').all

    raise ActiveRecord::RecordNotFound if !@event.can_edit?(current_user)
  end

  def update
    event = Event.find params[:id]

    raise ActiveRecord::RecordNotFound if !event.can_edit?(current_user)

    if params[:event][:event_keywords_attributes]
      event.event_keywords.each do |keyword|
        keyword.destroy
      end
    end

    event.attributes = params[:event]
    event.save

    if params[:event][:event_keywords_attributes] #HACK HACK HACKITY HACK
      redirect_to event
    else
      render :nothing => true
    end
  end

  def destroy
    event = Event.find params[:id]

    raise ActiveRecord::RecordNotFound if !event.can_edit?(current_user)

    event.canceled = true
    event.save

    if(event.upcoming)
      Resque.enqueue(Jobs::Email::EmailUserCancelEvent, event.id)
    end

    redirect_to :root
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