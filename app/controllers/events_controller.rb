class EventsController < ApplicationController
  before_filter :store_current_path, :only => [:show]
  before_filter :store_create_request, :only => [:create]
  before_filter :ss_authenticate_user!, :only => [:create, :edit, :update, :destroy, :post_to_facebook]
  before_filter :load_event, :only => [:show, :edit, :update, :destroy, :create_message, :send_message, :add_prompt, :report, :set_rsvp_text]
  before_filter :auth_edit_for_event, :only => [:edit, :update, :destroy, :set_rsvp_text, :report]
 
  def show    
    raise ActiveRecord::RecordNotFound if !@event.can_view?(current_user)

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

    @event.event_groups.build(:group_id => nil, :can_attend => true, :can_view => true)
    
    @location = @event.build_location

    @groups = current_user.groups if current_user

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
    @page_title = "Edit StreetMeet - #{@event.title}"

    @event_types = EventType.order('name').all

    @groups = current_user.groups if current_user

    if request.xhr?
      render "shared/ajax_load.js", :locals => {:file_name_var => 'events/edit.html.erb'}
    end
  end

  def update
    # => TODO, what happens if the save fails?s
    if create_or_edit_event(params, :edit)

      Resque.enqueue(Jobs::Email::EmailUserEditEvent, @event.id)

      redirect_to @event
    end
  end

  def destroy

    @event.canceled = true
    @event.save

    if(@event.upcoming)      
      Resque.enqueue(Jobs::Email::EmailUserCancelEvent, @event.id)
    end

    redirect_to :root
  end

  def streetmeet_of_the_week
    event = Event.where(:promoted => true).first
    render :partial => "smows/smow", :locals => {:event => event, :smow => event.smow}, :layout => false
  end


  def send_message    

    if @event && !params[:message].blank?
      Resque.enqueue(Jobs::Email::EmailEventUsersAdminMessage, @event.id, params[:message])
    end

    redirect_to @event
  end

  def add_prompt
    raise ActiveRecord::RecordNotFound unless current.god?
    if @event && !params[:message].blank?
      @event.update_attribute("prompt_question", params[:message])
    end
  end

  def report    
    require 'csv'
    csv_string = CSV.generate do |csv|
      # header row
      header_array = ["First Name", "Last Name", "Gender", "City", "Facebook Email"]
      @event.event_prompts.order(:sequence).each do |ep|
        header_array += [ep.prompt_question]
      end

      csv << header_array

      # data rows
      @event.event_rsvps.attending.each do |a|
        auth_data = a.user.authentications.first.auth_response["extra"]["raw_info"]
        
        merge_array = [
          a.user.first_name,
          a.user.last_name]
          
        merge_array += [
          auth_data["gender"],
          (auth_data["location"]["name"] rescue nil),
          auth_data["email"]
        ]

        @event.event_prompts.order(:sequence).each do |ep|
          merge_array += [a.event_prompt_answers.where(:event_prompt_id => ep.id).first.try(&:value) || "Clicked Continue"]
        end      

        csv << merge_array
      end
    end

    # send it to the browsah
    send_data csv_string,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=Event_#{@event.id}_report.csv"
  end

  def set_rsvp_text
    @event.update_attributes(:rsvp_text => params[:message]) unless params[:message].blank?
  end

  protected

  def store_create_request
    store_redirect(:controller => 'events', :action => 'create', :params => params)
  end
  def store_show_event_request
    store_redirect(:controller => 'events', :action => 'show', :params => params)
  end

  def load_event
    @event = Event.find params[:id]
  end

  def prepare_for_show
    @comments = @event.comments.order('created_at DESC').all
    @comment = @event.comments.build
    @invitation_user_connections = current_user.connections.includes(:to_user).order("connections.strength DESC NULLS LAST, users.last_name ASC").limit(50).all if current_user
  end

  def auth_edit_for_event
    raise ActiveRecord::RecordNotFound unless @event.can_edit?(current_user)
  end
end