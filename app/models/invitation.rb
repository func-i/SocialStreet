class Invitation < ActiveRecord::Base

  belongs_to :event
  belongs_to :rsvp
  belongs_to :user # from
  belongs_to :to_user, :class_name => "User" # to

  scope :to_user, lambda {|to_user| where(:to_user_id => to_user.id) }
  scope :for_event, lambda {|event| where(:event_id => event.id) }

end
