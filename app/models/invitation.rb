class Invitation < ActiveRecord::Base

  belongs_to :event
  belongs_to :rsvp
  belongs_to :user # from
  belongs_to :to_user, :class_name => "User" # to

  scope :to_user, lambda {|to_user| where(:to_user_id => to_user.id) }
  scope :for_event, lambda {|event| where(:event_id => event.id) }

  attr_accessor :facebook

  default_value_for :facebook, true

  after_create :post_to_facebook


  protected

  def post_to_facebook
    if to_user.sign_in_count.zero?
      fb_friend = user.facebook_user.friends.select{|f| f.identifier.eql?(to_user.fb_uid)}.first if user.facebook_user
      fb_friend.feed!(
        :message => "You have been invited to a SocialStreet Event: #{event.name}"
      ) if fb_friend && self.facebook
    end
  end


end
