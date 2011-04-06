class Activity < ActiveRecord::Base

  @@types = {
    :event_created => 'Event Created'
  }.freeze
  cattr_accessor :types

  belongs_to :event
  belongs_to :user
  belongs_to :reference, :polymorphic => true

  scope :most_recent_first, order("activities.occurred_at DESC")


  def of_type?(type)
    activity_type == Activity.types[type]
  end


end
