class M::EventsController < MobileController
  def show
    @event = Event.find params[:id]
    @rsvp = @event.event_rsvps.by_user(current_user).first if current_user

    @comments = @event.comments.order('created_at DESC').all
    @comment = @event.comments.build
  end

  def new
    @event = Event.new

    @event.start_date = Time.now.advance(:hours => 3).floor(15.minutes)
    @event.end_date = Time.now.advance(:hours => 6).floor(15.minutes)

    @event.event_groups.build(:group_id => nil, :can_attend => true, :can_view => true)

    @location = @event.build_location

    @event_types = EventType.order('name').all
  end

  def create
    if create_or_edit_event(params, :create)

      @event.reload

      if request.xhr?
        render :update do |page|
          page.redirect_to m_event_path(@event, :invite => true)
        end
      else
        redirect_to m_event_path(@event, :invite => true)
      end

    end
  end

  def edit
    @event = Event.find params[:id]
    
    raise ActiveRecord::RecordNotFound if !@event.can_edit?(current_user)

    @event_types = EventType.order('name').all
  end

  def update
    @event = Event.find params[:id]
    
    raise ActiveRecord::RecordNotFound if !@event.can_edit?(current_user)

    # => TODO, what happens if the save fails?s
    if create_or_edit_event(params, :edit)

      Resque.enqueue(Jobs::Email::EmailUserEditEvent, @event.id)
      
      if request.xhr?
        render :update do |page|
          page.redirect_to m_event_path(@event)
        end
      else
        redirect_to m_event_path(@event)
      end
    end
  end
  
end