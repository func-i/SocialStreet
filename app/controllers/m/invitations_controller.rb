class M::InvitationsController < MobileController
  before_filter :ss_authenticate_user!

  USERS_PER_PAGE = 30
  def new
    page = (params[:page] || 1).to_i
    offset = (page - 1) * USERS_PER_PAGE

    if(current_user)
      @invited_user_connections = current_user.connections.includes(:to_user).order("connections.strength DESC NULLS LAST, users.last_name ASC")

      @num_pages = (@invited_user_connections.count / USERS_PER_PAGE).ceil if 1 == page

      @invited_user_connections = @invited_user_connections.limit(USERS_PER_PAGE).offset(offset).all
    end

    @event = Event.find params[:event_id]
  end

  def create
    @event = Event.find params[:event_id]

    (params[:user_ids] || []).each do |user_id|
      if user = User.find(user_id)
        create_invitation(@event, current_user, user)
      end
    end

    redirect_to [:m, @event]
  end

  protected

  def create_invitation(event, from_user, to_user, email = nil)
    return if to_user && event.event_rsvps.where(:user_id => to_user).count > 0

    invitation = event.event_rsvps.create :user => to_user, :invitor => from_user, :status => EventRsvp.statuses[:invited], :email => email
    invitation.save

    Resque.enqueue(Jobs::Facebook::PostEventInvitation, from_user.id, to_user.id, @event.id)
  end
end