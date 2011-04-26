class Event < ActiveRecord::Base

  humanize_price :cost # creates cost_in_dollars getter/setter methods

  belongs_to :user
  belongs_to :searchable
  belongs_to :event_type
  belongs_to :action # if created through an activity stream
  
  has_many :rsvps
  has_many :actions
  has_many :comments, :as => :commentable
  
  accepts_nested_attributes_for :searchable

  attr_accessor :exclude_end_date

  before_validation :set_default_title
  before_create :build_initial_rsvp

  validates :name, :presence => true, :length => { :maximum => 60 }
  validates :starts_at, :presence => true
  validates :cost, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :minimum_attendees, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :allow_blank => true }
  validates :maximum_attendees, :numericality => {:only_integer => true, :greater_than_or_equal_to => 1, :allow_blank => true }
  validates :event_type, :presence => true
  validate :valid_dates
  validate :valid_maximum_attendees

  default_value_for :guests_allowed, true
  default_value_for :cost_in_dollars, 0

  scope :attended_by_user, lambda {|user|
    includes(:rsvps).where({ :rsvps => {:user_id => user.id, :status => Rsvp::statuses[:attending] }})
  }
  scope :upcoming, lambda {
    includes({:searchable => [:searchable_date_ranges] }).where("searchable_date_ranges.starts_at > ?", Time.zone.now)
    #joins(:searchable) & Searchable.on_or_after_date(Time.zone.now)
  }
  # SELECT xyz FROM events JOIN dateranges ON  dr.event_id = e.id WHERE dr.x = 1 OR dr.y = 1

  #  def exclude_end_date
  #    finishes_at ? 0 : 1
  #  end
  #
  #  def exclude_end_date=(exclude_end_date_val)
  #    if exclude_end_date_val != 0
  #      self.finishes_at = nil
  #      #TODO - Why doesn't this work?
  #    end
  #  end

  def location_address
    location.geocodable_address if location
  end

  def geo_located?
    location && location.geo_located?
  end

  # Stub
  def custom_image?
    false # for now
  end

  def num_attending
    rsvps.attending.size
  end
  def attendees_rsvps_list
    rsvps.attending
  end
  def num_waiting
    rsvps.waiting.size
  end
  def waitees_rsvps_list
    rsvps.waiting
  end

  def num_maybe_attending
    rsvps.maybe_attending.size
  end
  def maybe_attendees_rsvps_list
    rsvps.maybe_attending
  end

  def num_attending_or_maybe_attending
    rsvps.attending_or_maybe_attending.size
  end
  def attending_or_maybe_attendees_rsvps_list
    rsvps.attending_or_maybe_attending
  end

  def num_administrators
    rsvps.administrators.size
  end
  def administrators_rsvps_list
    rsvps.administrators
  end


  def free?
    !paid?
  end
  def paid?
    cost? && cost > 0
  end

  def number_of_attendees_needed
    if minimum_attendees?
      diff = minimum_attendees - num_attending
      if diff < 0
        return 0
      else
        return diff
      end
    else
      return 0
    end
  end

  def number_of_spots_left
    if maximum_attendees?
      diff = maximum_attendees - num_attending
      if diff < 0
        return 0
      else
        return diff
      end
    end
  end


  def editable_by?(user)
    rsvp = rsvps.by_user(user).first

    user == self.user || (rsvp && rsvp.administrator?)
  end

  # TEMPORARY HELPERS

  def location
    searchable.try(:location)
  end
  def latitude
    searchable.latitude
  end
  def longitude
    searchable.longitude
  end

  def event_type # assuming one event type per event (for now) - remove this helper when that is not the case
    searchable.searchable_event_types.first.try :event_type
  end

  def starts_at # assuming non recurring events, for now
    searchable.searchable_date_ranges.first.try :starts_at
  end
  
  def finishes_at  # assuming non recurring events, for now
    searchable.searchable_date_ranges.first.try :ends_at
  end
  
  protected

  
  def set_default_title
    if self.name.blank?
      self.name = event_type ? event_type.name : "Something"
      self.name << (" @ " + (location_address ? location_address : "Somewhere"))
      self.name << (" on " + (starts_at ? starts_at.to_s(:date_with_time) : "Sometime"))
    end
  end

  def valid_dates
    errors.add :finishes_at, 'must be after the event starts' if finishes_at && finishes_at <= starts_at
  end
  def valid_maximum_attendees
    if minimum_attendees? && maximum_attendees? && maximum_attendees < minimum_attendees
      errors.add :maximum_attendees, 'must be greater than or equal to the minimum'
    end
  end

  def build_initial_rsvp
    rsvps.build(:user=>user, :status => Rsvp.statuses[:attending], :administrator => 1) if rsvps.empty?
  end  
end
