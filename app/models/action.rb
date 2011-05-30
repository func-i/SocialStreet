class Action < ActiveRecord::Base

  @@types = {
    :event_created => 'Event Created',
    :event_rsvp_attending => 'Event RSVP Attending',
    :event_comment => 'Event Comment',
    :profile_comment => 'Profile Comment',
    :action_comment => 'Action Comment',
    :search_comment => 'Search Comment'
  }.freeze
  cattr_accessor :types

  belongs_to :event
  belongs_to :user
  belongs_to :to_user, :class_name => "User" # in the case of comments from one user to another (wall post)
  belongs_to :searchable, :dependent => :destroy
  belongs_to :action # tree based, but only 1 level deep
  belongs_to :reference, :polymorphic => true

  has_many :comments, :as => :commentable, :dependent => :destroy # comments can be made against an action. so an action has many comments
  has_many :actions, :dependent => :destroy # child actions (1 level deep). Eg child comments, child event creations, etc

  after_save :queue_action_processor

  scope :newest_first, order("actions.occurred_at DESC")
  scope :oldest_first, order("actions.occurred_at ASC")
  scope :top_level, where(:action_id => nil)

  # Expects type IDs, not EventType objects
  scope :of_type, lambda {|type_ids|
    where("events.event_type_id IN (?)", type_ids).includes(:event)
  }

  scope :connected_with, lambda {|user|
    joins(
      "INNER JOIN actions AS joined_actions
       ON (
            (
              joined_actions.action_id = actions.action_id
              OR joined_actions.action_id = actions.id
              OR joined_actions.id = actions.action_id
            )
            AND joined_actions.user_id = #{user.id}
          )"
    )
  }

  scope :threaded_with, lambda {|a|
    id = a.action_id || a.id
    where("actions.action_id = ? OR actions.id = ?", id, id)
  }

  scope :for_user, lambda { |user|
    includes(:reference).where("actions.user_id = ? OR actions.to_user_id = ?", user.id, user.id)
  }

  before_create :set_occurred_at
  before_validation :copy_searchable

  def of_type?(type)
    action_type == Action.types[type]
  end

  def user_list
    ([self.user] + actions.joins(:user).all.collect(&:user)).uniq
  end

  protected

  def set_occurred_at
    self.occurred_at = Time.zone.now
  end

  def copy_searchable
    unless self.searchable
      s = (action || event || reference)
      s = s.searchable if s && s.respond_to?(:searchable)
      self.searchable = s.clone(:include => [:searchable_date_ranges, :searchable_event_types]) if s
    end
  end

  def queue_action_processor
    puts "JOSH QUEUING (#{self.inspect})"
    Resque.enqueue(Jobs::ProcessNewActions, self.id)
  end

end
