class User < ActiveRecord::Base
  has_many :events
  
  has_many :event_rsvps #All rsvps that are for you (invitations/attending/not_attending...)
  has_many :invitations_created, :class_name => "EventRsvp", :foreign_key => "invitor_id" #Invitations we create

  has_many :comments

  has_many :connections
  has_many :incoming_connections, :class_name => "Connection", :foreign_key => "to_user_id"
  has_many :connected_users, :through => :connections, :source => :to_user


  validates :email, :uniqueness => { :allow_blank => true }
end
