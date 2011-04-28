class Searchable < ActiveRecord::Base

  geocoded_by :location_address
  
  belongs_to :location

  has_one :event
  has_one :action
  has_one :comment

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
    includes(:searchable_date_ranges).where("searchable_date_ranges.dow IN (?) OR EXTRACT(DOW FROM searchable_date_ranges.starts_at#{interval}) IN (?)", days, days)
  }
  
  scope :on_days_or_in_date_range, lambda {|days, from_date, to_date, inclusive|
    if from_date && to_date && (from_date = Time.zone.parse(from_date)) && (to_date = Time.zone.parse(to_date))
      from_date = from_date.beginning_of_day
      to_date = to_date.end_of_day

      if days
        interval = sql_interval_for_utc_offset
        if inclusive
          includes(:searchable_date_ranges).where("searchable_date_ranges.dow IN (?) OR EXTRACT(DOW FROM searchable_date_ranges.starts_at#{interval}) IN (?) OR (searchable_date_ranges.starts_at BETWEEN ? AND ?)", days, days, from_date, to_date)
        else
          #Exclusion should be treated as an OR condition, because we want to remove the days regardless q
          includes(:searchable_date_ranges).where("(searchable_date_ranges.dow IN (?) OR EXTRACT(DOW FROM searchable_date_ranges.starts_at#{interval}) IN (?)) AND (searchable_date_ranges.starts_at NOT BETWEEN ? AND ?)", days, days, from_date, to_date)
        end
      else
        includes(:searchable_date_ranges).where("searchable_date_ranges.starts_at #{'NOT' if !inclusive} BETWEEN ? AND ?", from_date, to_date)
      end
    elsif !days.blank?
      starts_at_days(days)
    end
  }

  # Expects type IDs, not EventType objects
  scope :with_event_types, lambda {|type_ids|
    includes(:searchable_event_types).where("searchable_event_types.event_type_id IN (?)", type_ids)
  }

  scope :excluding_nested_actions, where("searchables.id NOT IN (SELECT searchable_id FROM actions WHERE actions.searchable_id = searchables.id AND actions.action_id IS NOT NULL)")
  # for some reason :excluding_comments scope causes a PG SQL ERROR and I don't know why, yet - KV
  #  scope :excluding_comments, where("searchables.id NOT IN (SELECT searchable_id FROM comments WHERE comments.searchable.id = searchables.id)")
  scope :excluding_comments, joins("LEFT OUTER JOIN comments ON comments.searchable_id = searchables.id").where("comments.id IS NULL")
  scope :excluding_subscriptions, joins("LEFT OUTER JOIN search_subscriptions ON search_subscriptions.searchable_id = searchables.id").where("search_subscriptions.id IS NULL")
  # called from the explore controller/action
  scope :with_excludes_for_explore, excluding_nested_actions.excluding_subscriptions.excluding_comments
  

  def location_address
    location.geocodable_address if location
  end

  def geo_located?
    location && location.geo_located?
  end

  def global_comment?
    comment
  end

  # search filter params from the form
  def self.new_from_params(params)
    attrs = {
      
    }
    
    attrs[:location_attributes] = { :text => params[:location], :radius => params[:radius] } unless params[:location].blank?
    attrs[:searchable_date_ranges_attributes] = []

    if !params[:from_date].blank? || !params[:to_date].blank?
      attrs[:searchable_date_ranges_attributes] << {
        :start_date => params[:from_date].blank? ? nil : Date.parse(params[:from_date]),
        :end_date => params[:to_date].blank? ? nil : Date.parse(params[:to_date]),
        :inclusive => params[:inclusive].blank? ? false : (params[:inclusive]=="on" ? true : false)
      }
    end

    if params[:from_time].to_i > 0 || params[:to_time].to_i < 1439
      attrs[:searchable_date_ranges_attributes] << {
        :start_time => params[:from_time].to_i,
        :end_time => params[:to_time].to_i
      }
    end

    unless params[:days].blank?
      params[:days].each do |day|
        attrs[:searchable_date_ranges_attributes] << {:dow => day}
      end
    end
    
    unless params[:types].blank?
      attrs[:searchable_event_types_attributes] = []
      params[:types].each do |t_id|
        attrs[:searchable_event_types_attributes] << { :event_type_id => t_id }
      end
    end

    new(attrs)
  end

  def url_params
    params = {}

    #Event Types
    params[:types] = searchable_event_types.collect {|searchable_event_type| searchable_event_type.event_type_id} unless searchable_event_types.blank?

    #Location
    if location
      params[:location] = location.text
      params[:radius] = location.radius
    end

    unless searchable_date_ranges.blank?
      #Days of the week
      params[:days] = searchable_date_ranges.collect{|searchable_date_range| searchable_date_range.dow}.compact

      #Date Ranges
      params[:from_time] = searchable_date_ranges.collect{|searchable_date_range| searchable_date_range.start_time}.compact.first
      params[:to_time] = searchable_date_ranges.collect{|searchable_date_range| searchable_date_range.end_time}.compact.first
      params[:inclusive] = searchable_date_ranges.collect{|searchable_date_range| searchable_date_range.inclusive}.compact.first

      #Time Ranges
      params[:from_date] = searchable_date_ranges.collect{|searchable_date_range| searchable_date_range.start_date}.compact.first
      params[:to_date] = searchable_date_ranges.collect{|searchable_date_range| searchable_date_range.end_date}.compact.first
    end

    return params
  end

  protected

  def cache_lat_lng
    if location && !location.new_record?
      self.latitude = location.latitude
      self.longitude = location.longitude
    end
  end

  def self.day_selected?(params, day)
    params[:days] && params[:days].include?(day.to_s)
  end


end
