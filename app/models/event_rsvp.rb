class EventRsvp < ActiveRecord::Base
  @@statuses = {
    :attending => 'Attending',
    :not_attending => 'Not Attending',
    :maybe_attending => 'Maybe',
    :invited => 'Invited'
  }.freeze
  cattr_accessor :statuses

  belongs_to :user
  belongs_to :event
  belongs_to :invitor, :class_name => "User"

  validates :event_id, :uniqueness => {:scope => [:user_id] }

  scope :for_event, lambda {|event| where(:event_id => event.id) }
  scope :by_user, lambda {|user| where(:user_id => user.id) }

  scope :attending, where(:status => @@statuses[:attending])
  scope :attending_or_maybe_attending, where("event_rsvps.status IN (?)", @@statuses.except(:not_attending).except(:invited).values)
end
