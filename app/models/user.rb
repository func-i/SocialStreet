class User < ActiveRecord::Base
  has_many :events
  
  has_many :event_rsvps #All rsvps that are for you (invitations/attending/not_attending...)
  has_many :invitations_created, :class_name => "EventRsvp", :foreign_key => "invitor_id" #Invitations we create

  validates :email, :uniqueness => { :allow_blank => true }
end
