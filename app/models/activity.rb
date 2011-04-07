class Activity < ActiveRecord::Base

  @@types = {
    :event_created => 'Event Created',
    :event_rsvp_attending => 'Event RSVP Attending',
    :event_comment => 'Event Comment'
  }.freeze
  cattr_accessor :types

  belongs_to :event
  belongs_to :user
  belongs_to :reference, :polymorphic => true

  scope :most_recent_first, order("activities.occurred_at DESC")

  before_create :set_occurred_at


  def of_type?(type)
    activity_type == Activity.types[type]
  end

  protected

  def set_occurred_at
    self.occurred_at = Time.zone.now
  end

end
