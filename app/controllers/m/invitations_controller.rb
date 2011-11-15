class M::InvitationsController < MobileController
  def new
    if current_user.nil?
      render :nothing => true
      return
    end

    @event = Event.find params[:event_id]
  end
end