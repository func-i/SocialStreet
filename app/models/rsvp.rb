class Rsvp < ActiveRecord::Base
  @@statuses = {
    :attending => 'Attending',
    :not_attending => 'Not Attending',
    :maybe => 'Maybe',
  }
  cattr_accessor :statuses

  belongs_to :user
  belongs_to :event

  has_many :activities, :as => :reference

  def available_statuses
    if event.maximum_attendees
      @@statuses.except(:maybe)
    else
      @@statuses
    end
  end

  validates :event_id, :uniqueness => {:scope => [:user_id] }

  scope :for_event, lambda {|event| where(:event_id => event.id) }
  scope :by_user, lambda {|user| where(:user_id => user.id) }
  scope :attending, where(:status => @@statuses[:attending])

  validate :validate_event_status

  def validate_event_status
    if !available_statuses.has_value?(self.status)
      errors.add(:base, "RSVP status not allowed")
    end
  end


end
