class Invitation < ActiveRecord::Base

  belongs_to :event
  belongs_to :rsvp
  belongs_to :user # from
  belongs_to :to_user, :class_name => "User" # to

  scope :to_user, lambda {|to_user| where(:to_user_id => to_user.id) }
  scope :for_event, lambda {|event| where(:event_id => event.id) }

  scope :still_valid, lambda{ joins(:event).merge(Event.upcoming)} # TODO - doesn't work

  #after_create :post_to_facebook
  #after_create :send_email

  protected

  def post_to_facebook
    # Only post invitations to facebook walls for users that haven't yet signed into SocialStreet
  end

  # TODO: Perhaps don't send an email if we are writing to their facebook wall ? 
  def send_email
    Resque.enqueue(Jobs::EmailUserEventInvitation, self.id)
  end

end
