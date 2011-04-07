class Rsvp < ActiveRecord::Base
  @@statuses = {
    :attending => 'Attending',
    :not_attending => 'Not Attending',
    :maybe_attending => 'Maybe',
  }
  cattr_accessor :statuses
  #attr_accessor :administrator

  belongs_to :user
  belongs_to :event

  has_many :activities, :as => :reference

  validates :event_id, :uniqueness => {:scope => [:user_id] }
  validates :administrator, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :allow_blank => true }

  scope :for_event, lambda {|event| where(:event_id => event.id) }
  scope :by_user, lambda {|user| where(:user_id => user.id) }
  scope :attending, where(:status => @@statuses[:attending])
  scope :maybe_attending, where(:status => @@statuses[:maybe_attending])
  scope :attending_or_maybe_attending, where("status IN (?)", @@statuses.except(:not_attending).values)
  scope :administrators, where('administrator IS NOT NULL AND administrator > 0')

  validate :validate_event_status

  def validate_event_status
    if !available_statuses.has_value?(self.status)
      errors.add :status, "not allowed"
    end
  end

  def available_statuses
    if event && event.maximum_attendees
      @@statuses.except(:maybe)
    else
      @@statuses
    end
  end



end
