class Event < ActiveRecord::Base

  geocoded_by :location_address

  belongs_to :location
  accepts_nested_attributes_for :location

  before_save :cache_lat_lng
  before_save :cache_day_of_week

  validates :name, :presence => true, :length => { :maximum => 60 }
  #  validates :description, :length => { :maximum => 200 }
  validates :held_on, :presence => true
  validates :cost, :presence => true, :numericality => { :only_integer => true }, :unless => :free?

  scope :on_or_after_date, lambda {|date|
    date = Time.zone.parse(date)
    where('events.held_on >= ?', date.beginning_of_day) if date
  }
  scope :on_or_before_date, lambda {|date|
    date = Time.zone.parse(date) # 
    where('events.held_on <= ?', date.end_of_day) if date
  }
  scope :at_or_after_time_of_day, lambda {|time|
    interval = sql_interval_for_utc_offset
    where("date_part('hour', events.held_on#{interval}) * 60 + date_part('minute', events.held_on#{interval}) >= ?", time)
  }
  scope :at_or_before_time_of_day, lambda {|time|
    interval = sql_interval_for_utc_offset
    where("date_part('hour', events.held_on#{interval}) * 60 + date_part('minute', events.held_on#{interval}) <= ?", time)
  }
  scope :held_on_days, lambda { |days| # days would look like ['0', '1', '2', ... ] which means ['sun', 'mon', 'tues']
    # TODO: events.held_on needs to be offset to the user's / app's timezone not UTC which it is now - KV
    where(:held_on_day_of_week => days)
  }
  scope :on_days_or_in_date_range, lambda {|days, from_date, to_date|
    queries = [] # the date range queries are inside an OR so we build them like this - Don't know of a better way (yet) - KV
    if from_date && from_date = Time.zone.parse(from_date)
      queries << "events.held_on >= '#{from_date.beginning_of_day.to_s(:db)}'"
    end
    if to_date && to_date = Time.zone.parse(to_date)
      queries << "events.held_on <= '#{to_date.end_of_day.to_s(:db)}'"
    end
    date_query = "OR (#{queries.join(" AND ")})" unless queries.blank? # Don't want "OR ()" showing up in there (SQL Error)
    where("events.held_on_day_of_week IN (?) #{date_query}", days)
  }

  def location_address
    location.geocodable_address if location
  end

  def self.sql_interval_for_utc_offset
    interval = Time.zone.utc_offset / 60 / 60
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

  def cache_day_of_week
    if held_on? # should always be set, but just incase
      self.held_on_day_of_week = held_on.wday # 0 is sunday
    end
  end




end
