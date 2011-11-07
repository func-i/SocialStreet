class EventRsvpsController < ApplicationController
  before_filter :store_new_rsvp_request, :only => [:new]
  before_filter :ss_authenticate_user!, :only => [:new, :edit]

  def new
    if !attending_event_rsvp(params[:event_id].to_i)
      raise 'Sorry, there was an error. We are doing our best to see that no one ever makes an error again'
    end

    if request.xhr?
      render :update do |page|
        page.redirect_to event_path(@event, :invite => true)
      end
    else
      redirect_to event_path(@event, :invite => true)
    end
  end

  def edit
    @event = Event.find params[:event_id].to_i

    rsvp = @event.event_rsvps.by_user(current_user).first if current_user

    rsvp.status = EventRsvp.statuses[:not_attending] if rsvp

    if !rsvp || !rsvp.save
      raise 'Sorry, there was an error. We are doing our best to see that no one ever makes an error again'
    end
  end

  protected

  def store_new_rsvp_request
    store_redirect(:controller => 'event_rsvps', :action => 'new', :params => params)
  end
end