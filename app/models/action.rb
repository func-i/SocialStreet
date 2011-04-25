class Action < ActiveRecord::Base

  @@types = {
    :event_created => 'Event Created',
    :event_rsvp_attending => 'Event RSVP Attending',
    :event_comment => 'Event Comment',
    :profile_comment => 'Profile Comment',
    :action_comment => 'Action Comment'
  }.freeze
  cattr_accessor :types

  belongs_to :event
  belongs_to :user
  belongs_to :searchable
  belongs_to :action # tree based, but only 1 level deep
  belongs_to :reference, :polymorphic => true

  has_many :comments, :as => :commentable # comments can be made against an action. so an action has many comments
  has_many :actions # child actions (1 level deep). Eg child comments, child event creations, etc

  scope :newest_first, order("actions.occurred_at DESC")
  scope :oldest_first, order("actions.occurred_at ASC")
  scope :top_level, where(:action_id => nil)

  # Expects type IDs, not EventType objects
  scope :of_type, lambda {|type_ids|
    where("events.event_type_id IN (?)", type_ids).includes(:event)
  }

  before_create :set_occurred_at


  def of_type?(type)
    action_type == Action.types[type]
  end

  protected

  def set_occurred_at
    self.occurred_at = Time.zone.now
  end

end
