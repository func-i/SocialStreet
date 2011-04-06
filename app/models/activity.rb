class Activity < ActiveRecord::Base

  @@types = {
    :event_created => 'Event Created',
    :event_rsvp_attending => 'Event RSVP Attending'
  }.freeze
  cattr_accessor :types

  belongs_to :event
  belongs_to :user
  belongs_to :reference, :polymorphic => true

  scope :most_recent_first, order("activities.occurred_at DESC")

  default_value_for :occurred_at do
    Time.zone.now
  end


  def of_type?(type)
    activity_type == Activity.types[type]
  end


end
