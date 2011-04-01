class Event < ActiveRecord::Base

  geocoded_by :location_address

  belongs_to :location
  accepts_nested_attributes_for :location

  before_save :cache_lat_lng

  validates :name, :presence => true, :length => { :maximum => 60 }
  #  validates :description, :length => { :maximum => 200 }
  validates :starts_at, :presence => true
  validates :cost, :presence => true, :numericality => { :only_integer => true }, :unless => :free?

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
  
end
