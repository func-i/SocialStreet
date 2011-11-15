class M::EventRsvpsController < MobileController
  def new
    rtn_code = attending_event_rsvp(params[:event_id].to_i)

    if -1 == rtn_code
      raise 'Sorry, there was an error. We are doing our best to see that no one ever makes an error again'
    else
      if request.xhr?
        render :update do |page|
          page.redirect_to m_event_path(@event, :invited => true)
        end
      else
        redirect_to m_event_path(@event, :invited => true)
      end
    end
  end

  def edit
    @event = Event.find params[:event_id].to_i

    rsvp = @event.event_rsvps.by_user(current_user).first if current_user

    rsvp.status = EventRsvp.statuses[:not_attending] if rsvp

    if !rsvp || !rsvp.save
      raise 'Sorry, there was an error. We are doing our best to see that no one ever makes an error again'
    end

    redirect_to m_event_path(@event)
  end
end