class Rsvp < ActiveRecord::Base

  @@statuses = {
    :attending => 'Attending',
    :not_attending => 'Not Attending',
    :maybe_attending => 'Maybe',
  }
  cattr_accessor :statuses
  attr_accessor :skip_facebook

  belongs_to :user
  belongs_to :event
  
  has_many :actions, :as => :reference
  has_many :invitations, :dependent => :destroy # invitations sent out by the user of this rsvp also link to this rsvp
  has_one :feedback, :dependent => :destroy

  validates :event_id, :uniqueness => {:scope => [:user_id] }
  validate :validate_event_status

  scope :for_event, lambda {|event| where(:event_id => event.id) }
  scope :by_user, lambda {|user| where(:user_id => user.id) }
  scope :attending, where(:status => @@statuses[:attending], :waiting => false)
  scope :waiting, where(:status => @@statuses[:attending], :waiting => true)
  scope :maybe_attending, where(:status => @@statuses[:maybe_attending])
  scope :attending_or_maybe_attending, where("rsvps.status IN (?)", @@statuses.except(:not_attending).values)
  scope :administrators, where(:administrator => true)

  scope :excluding_user, lambda {|user| where("rsvps.user_id <> ?", user.id) }

  scope :also_attended_by, lambda {|user| 
    joins(
      "INNER JOIN rsvps AS joined_rsvps ON joined_rsvps.event_id = rsvps.event_id AND joined_rsvps.user_id = #{user.id}"
    ).where("joined_rsvps.status IN (?)", @@statuses.except(:not_attending).values)
  }

  default_value_for :administrator, false
  default_value_for :waiting, false

  before_save :set_is_waiting
  before_save :create_feedback

  after_save {|record| record.user.post_to_facebook_wall(
      :message => "Changed RSVP status for SocialStreet Event #{record.event.name} to #{record.status}"
    ) unless skip_facebook }

  def available_statuses
    if event && event.maximum_attendees
      return @@statuses.except(:maybe_attending)
    else
      return @@statuses
    end
  end

  protected

  def attending?
    self.status == @@statuses[:attending]
  end

  def validate_event_status
    if !available_statuses.has_value?(self.status)
      errors.add :status, "not allowed"
    end
  end

  # This is causing really wierd behavior and not working - not sure why - wtf ? - KV
  #  def set_is_waiting2
  #    self.waiting = attending? && event.number_of_spots_left == 0 # spots_left may be nil
  #  end

  def set_is_waiting
    self.waiting = false

    if status == @@statuses[:attending]
      spots_left = event.number_of_spots_left
      if spots_left && spots_left == 0
        self.waiting = true
      end
    end
  end
  
  def attending_or_maybe_attending?
    self.status == Rsvp.statuses[:attending] || self.status == Rsvp.statuses[:maybe_attending]
  end

  def create_feedback
    if self.status_changed?
      if attending_or_maybe_attending?  # attending therefore we want feedback from them
        self.feedback = Feedback.new unless self.feedback
        self.feedback.save
      elsif self.feedback && !self.feedback.responded? # not attending, therefore no feedback required
        self.feedback.destroy
      end
    end
  end

end
