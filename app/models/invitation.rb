class Invitation < ActiveRecord::Base

  belongs_to :event
  belongs_to :rsvp
  belongs_to :user # from
  belongs_to :to_user, :class_name => "User" # to

  


end
