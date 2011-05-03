class Invitation < ActiveRecord::Base

  belongs_to :event
  belongs_to :rsvp
  belongs_to :user # from
  belongs_to :to_user, :class_name => "User" # to

  scope :by_to_user, lambda {|to_user| where(:to_user_id => to_user.id) }  

end
