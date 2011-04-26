class Searchable < ActiveRecord::Base

  geocoded_by :location_address
  
  belongs_to :location

  has_one :event
  has_one :action

  has_many :searchable_date_ranges
  has_many :searchable_event_types
  has_many :event_types, :through => :searchable_event_types

  accepts_nested_attributes_for :location
  accepts_nested_attributes_for :searchable_date_ranges
  accepts_nested_attributes_for :searchable_event_types

  before_save :cache_lat_lng

  scope :on_or_after_date, lambda {|date|
    date = Time.zone.parse(date) if date.is_a? String
    includes(:searchable_date_ranges).where('searchable_date_ranges.starts_at >= ?', date.beginning_of_day) if date
  }
  scope :on_or_before_date, lambda {|date|
    date = Time.zone.parse(date)
    includes(:searchable_date_ranges).where('searchable_date_ranges.starts_at <= ?', date.end_of_day) if date
  }
  scope :at_or_after_time_of_day, lambda {|time|
    interval = sql_interval_for_utc_offset
    includes(:searchable_date_ranges).where("date_part('hour', searchable_date_ranges.starts_at#{interval}) * 60 + date_part('minute', searchable_date_ranges.starts_at#{interval}) >= ?", time)
  }
  scope :at_or_before_time_of_day, lambda {|time|
    interval = sql_interval_for_utc_offset
    includes(:searchable_date_ranges).where("date_part('hour', searchable_date_ranges.starts_at#{interval}) * 60 + date_part('minute', searchable_date_ranges.starts_at#{interval}) <= ?", time)
  }
  scope :starts_at_days, lambda { |days| # days would look like ['0', '1', '2', ... ] which means ['sun', 'mon', 'tues']
    interval = sql_interval_for_utc_offset
    includes(:searchable_date_ranges).where("EXTRACT(DOW FROM searchable_date_ranges.starts_at#{interval}) IN (?)", days)
  }
  scope :on_days_or_in_date_range, lambda {|days, from_date, to_date, inclusive|
    if from_date && to_date && (from_date = Time.zone.parse(from_date)) && (to_date = Time.zone.parse(to_date))
      from_date = from_date.beginning_of_day
      to_date = to_date.end_of_day

      if days
        interval = sql_interval_for_utc_offset
        if inclusive
          includes(:searchable_date_ranges).where("EXTRACT(DOW FROM searchable_date_ranges.starts_at#{interval}) IN (?) OR (searchable_date_ranges.starts_at BETWEEN ? AND ?)", days, from_date, to_date)
        else
          #Exclusion should be treated as an OR condition, because we want to remove the days regardless q
          includes(:searchable_date_ranges).where("EXTRACT(DOW FROM searchable_date_ranges.starts_at#{interval}) IN (?) AND (searchable_date_ranges.starts_at NOT BETWEEN ? AND ?)", days, from_date, to_date)
        end
      else
        includes(:searchable_date_ranges).where("searchable_date_ranges.starts_at #{ 'NOT' if !inclusive } BETWEEN ? AND ?", from_date, to_date)
      end
    elsif !days.blank?
      interval = sql_interval_for_utc_offset
      includes(:searchable_date_ranges).where("EXTRACT(DOW FROM searchable_date_ranges.starts_at#{interval}) IN (?)", days)
    end
  }

  # Expects type IDs, not EventType objects
  scope :with_event_types, lambda {|type_ids|
    includes(:searchable_event_types).where("searchable_event_types.event_type_id IN (?)", type_ids)
  }

  def location_address
    location.geocodable_address if location
  end

  def geo_located?
    location && location.geo_located?
  end

  def comment
    if action
      action.reference if action.reference.is_a? Comment
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
