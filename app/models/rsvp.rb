class Rsvp < ActiveRecord::Base
  before_save :set_is_waiting
  before_save :create_feedback

  @@statuses = {
    :attending => 'Attending',
    :not_attending => 'Not Attending',
    :maybe_attending => 'Maybe',
  }
  cattr_accessor :statuses

  belongs_to :user
  belongs_to :event
  
  has_many :actions, :as => :reference
  has_many :invitations # invitations sent out by the user of this rsvp also link to this rsvp
  has_one :feedback, :dependent => :destroy

  validates :event_id, :uniqueness => {:scope => [:user_id] }
  validate :validate_event_status

  scope :for_event, lambda {|event| where(:event_id => event.id) }
  scope :by_user, lambda {|user| where(:user_id => user.id) }
  scope :attending, where(:status => @@statuses[:attending], :waiting => false)
  scope :waiting, where(:status => @@statuses[:attending], :waiting => true)
  scope :maybe_attending, where(:status => @@statuses[:maybe_attending])
  scope :attending_or_maybe_attending, where("status IN (?)", @@statuses.except(:not_attending).values)
  scope :administrators, where(:administrator => true)

  default_value_for :administrator, false
  default_value_for :waiting, false


  def available_statuses
    if event && event.maximum_attendees
      return @@statuses.except(:maybe_attending)
    else
      return @@statuses
    end
  end

  protected

  def validate_event_status
    if !available_statuses.has_value?(self.status)
      errors.add :status, "not allowed"
    end
  end

  def set_is_waiting
    self.waiting = false

    if status == @@statuses[:attending]
      spots_left = event.number_of_spots_left
      if spots_left && spots_left == 0
        self.waiting = true
      end
    end

  end

  def create_feedback
    if self.status == Rsvp.statuses[:attending] || self.status == Rsvp.statuses[:maybe_attending]
      if self.feedback
        return
      else
        #Create feedback record
        self.feedback = Feedback.new()

        if self.feedback.save
          return
        else
          return
        end
      end
    else
      if self.feedback && !self.feedback.responded?
        self.feedback.destroy
      else
        return
      end
    end
  end

end
