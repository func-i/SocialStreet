class Invitation < ActiveRecord::Base

  belongs_to :event
  belongs_to :rsvp
  belongs_to :user # from
  belongs_to :to_user, :class_name => "User" # to

  scope :to_user, lambda {|to_user| where(:to_user_id => to_user.id) }
  scope :for_event, lambda {|event| where(:event_id => event.id) }

  scope :still_valid, lambda{ joins(:event).merge(Event.upcoming)} # TODO - doesn't work

  attr_accessor :facebook

  # => Because this is an accessor the checkbox on the forms will populate it with "0"
  # => If it is set to "0" then set it to false
  def facebook=(val)
    @facebook = (val.eql?("0") ? false : val)
  end

  default_value_for :facebook, true

  after_create :post_to_facebook
  after_create :send_email

  protected

  def post_to_facebook
    # Only post invitations to facebook walls for users that haven't yet signed into SocialStreet
    if to_user.sign_in_count.zero?
      fb_friend = user.facebook_user.friends.select{|f| f.identifier.eql?(to_user.fb_uid)}.first if user.facebook_user
      fb_friend.feed!(
        :message => "You have been invited to a SocialStreet Event: #{event.name}"
      ) if fb_friend && self.facebook
    end
  end

  # TODO: Perhaps don't send an email if we are writing to their facebook wall ? 
  def send_email
    Resque.enqueue(Jobs::EmailUserEventInvitation, self.id)
  end

end
