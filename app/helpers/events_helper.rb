module EventsHelper
  def create_event(params)
    event = Event.new params[:event]
    event.user = current_user if current_user # TODO: remove if statement when enforced.

    if event.save
      return event
    else
      prepare_for_form
      return :new
    end

  end
end
