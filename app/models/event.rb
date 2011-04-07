class Event < ActiveRecord::Base

  geocoded_by :location_address
  humanize_price :cost # creates cost_in_dollars getter/setter methods

  belongs_to :user
  belongs_to :location
  belongs_to :event_type
  
  has_many :rsvps
  has_many :activities
  has_many :comments, :as => :commentable
  
  accepts_nested_attributes_for :location

  before_save :cache_lat_lng
  before_create :build_initial_rsvp

  validates :name, :presence => true, :length => { :maximum => 60 }
  validates :starts_at, :presence => true
  validates :cost, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :minimum_attendees, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :allow_blank => true }
  validates :maximum_attendees, :numericality => {:only_integer => true, :greater_than_or_equal_to => 1, :allow_blank => true }
  validates :event_type, :presence => true
  validate :valid_dates
  validate :valid_maximum_attendees

  default_value_for :starts_at do
    Time.zone.now.advance(:hours => 3).floor(15.minutes)
  end
  default_value_for :finishes_at do |e|
    (e.starts_at || Time.zone.now.advance(:hours => 3)).advance(:hours => 3).floor(15.minutes)
  end
  default_value_for :name do |e|
    if e.event_type
      e.event_type.name
    end
  end
  default_value_for :guests_allowed, true
  default_value_for :cost_in_dollars, 0

  scope :on_or_after_date, lambda {|date|
    date = Time.zone.parse(date)
    where('events.starts_at >= ?', date.beginning_of_day) if date
  }
  scope :on_or_before_date, lambda {|date|
    date = Time.zone.parse(date) # 
    where('events.starts_at <= ?', date.end_of_day) if date
  }
  scope :at_or_after_time_of_day, lambda {|time|
    interval = sql_interval_for_utc_offset
    where("date_part('hour', events.starts_at#{interval}) * 60 + date_part('minute', events.starts_at#{interval}) >= ?", time)
  }
  scope :at_or_before_time_of_day, lambda {|time|
    interval = sql_interval_for_utc_offset
    where("date_part('hour', events.starts_at#{interval}) * 60 + date_part('minute', events.starts_at#{interval}) <= ?", time)
  }
  scope :starts_at_days, lambda { |days| # days would look like ['0', '1', '2', ... ] which means ['sun', 'mon', 'tues']
    interval = sql_interval_for_utc_offset
    where("EXTRACT(DOW FROM events.starts_at#{interval}) IN (?)", days)
  }
  scope :on_days_or_in_date_range, lambda {|days, from_date, to_date|
    queries = [] # the date range queries are inside an OR so we build them like this - Don't know of a better way (yet) - KV
    if from_date && from_date = Time.zone.parse(from_date)
      queries << "events.starts_at >= '#{from_date.beginning_of_day.to_s(:db)}'"
    end
    if to_date && to_date = Time.zone.parse(to_date)
      queries << "events.starts_at <= '#{to_date.end_of_day.to_s(:db)}'"
    end
    date_query = "OR (#{queries.join(" AND ")})" unless queries.blank? # Don't want "OR ()" showing up in there (SQL Error)
    interval = sql_interval_for_utc_offset
    where("EXTRACT(DOW FROM events.starts_at#{interval}) IN (?) #{date_query}", days)
  }

  # Expects type IDs, not EventType objects
  scope :of_type, lambda {|type_ids|
    where(:event_type_id => type_ids)
  }

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
  def num_attending_or_maybe
    rsvps.attending.size + rsvps.maybe_attending.size
  end

  def num_administrators
    rsvps.administrators.size
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

  def self.sql_interval_for_utc_offset
    interval = Time.zone.now.utc_offset / 60 / 60
    interval = if interval < 0
      " - interval '#{interval.abs} hours'"
    elsif interval > 0
      " + interval '#{interval} hours'"
    else
      ""
    end
  end

  protected

  def cache_lat_lng
    if location && !location.new_record?
      self.latitude = location.latitude
      self.longitude = location.longitude
    end
  end

  def valid_dates
    if finishes_at?
      errors.add :finishes_at, 'must be after the event starts' if finishes_at <= starts_at
    end
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
