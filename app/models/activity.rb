class Activity < ActiveRecord::Base

  @@types = {
    :event_created => 'Event Created',
    :event_rsvp_attending => 'Event RSVP Attending',
    :event_comment => 'Event Comment',
    :activity_comment => 'Activity Comment'
  }.freeze
  cattr_accessor :types

  belongs_to :event
  belongs_to :user
  belongs_to :activity # tree based, but only 1 level deep
  belongs_to :reference, :polymorphic => true

  has_many :comments, :as => :commentable
  has_many :activities

  scope :newest_first, order("activities.occurred_at DESC")
  scope :oldest_first, order("activities.occurred_at ASC")

  before_create :set_occurred_at


  def of_type?(type)
    activity_type == Activity.types[type]
  end

  protected

  def set_occurred_at
    self.occurred_at = Time.zone.now
  end

end
