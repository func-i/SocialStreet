class SearchSubscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :searchable, :dependent => :destroy

  @@frequencies = {
    :immediate => 'Immediate',
    :daily => 'Daily',
    :weekly => 'Weekly',
    :none => 'None'
  }
  cattr_accessor :frequencies

  validates :name, :presence => true

  default_value_for :frequency, @@frequencies[:daily]

  scope :overlapping_date_ranges, lambda { |start_date, start_time, end_date, end_time|
    #this function assumes that each date has its own record...TODO - remake searchable_date_ranges
    #start date/time is within subscription bounds
    query = "(searchable_date_range.start_date <= #{start_date}
            AND searchable_date_range.end_date >= #{start_date}
            AND searchable_date_range.start_time <= #{start_time}
            AND searchable_date_range.end_time >= #{start_time})"

    if end_date && end_time
      query = query.where("searchable_date_range")
    end

    joins("LEFT OUTER JOIN searchable_date_range
            ON searchable_date_range.searchable_id = search_subscriptions.searchable_id")
  }

  scope :bounding_location, lambda { |latitude, longitude|
    joins("INNER JOIN locations L
         ON searchables.location_id = locations.id AND
           (
              locations.sw_lat <= #{latitude} AND
              locations.ne_lat >= #{latitude} AND
              (
                (
                  locations.sw_lng >= L.ne_lng AND
                  locations.sw_lng >= #{longitude} AND
                  locations.ne_lng <= #{longitude} AND
                ) OR (
                  locations.sw_lng <= L.ne_lng AND
                  locations.sw_lng <= #{longitude} AND
                  locations.ne_lng >= #{longitude} AND
                )
              )
           )"
    )
  }

  def self.find_matching_subscriptions(latitude, longitude, event_type_id_array = nil, start_date = nil, start_time = nil, end_date = nil, end_time = nil)
    #location bounds
    subscriptions = subscriptions.bounding_location(latitude, longitude)

    #event types
    subscriptions = subscriptions.with_event_types_or_null(event_type_id_array)

    #date range - TODO
    subscriptions = subscriptions.overlapping_date_ranges(start_date, start_time, end_date, end_time)
  end

  def matches_date_ranges?(date_ranges)
    !!searchable.searchable_date_ranges.select { |dr| dr.overlapping_with? date_ranges }.first
  end


  def self.matching_event(event)

    #type
    type = event.event_type

    #date
    starts = event.starts_at
    ends = event.finishes_at

    #location
    location_lat = event.latitude
    location_long = event.longitude

    searchables = Searchable.with_only_subscriptions.with_event_types([type.id]).bounds...
#    s.matching_date_ranges(event.searchable.searchable_date_ranges.all)

    #TODO - Location
    searchables.all.select { |s| s.search_subscription.matches_date_ranges?(event.searchable.searchable_date_ranges.all) }
  end

  def self.new_from_params(params)
    searchable = Searchable.new_from_params(params)
    SearchSubscription.new(:searchable => searchable)
  end

  def url_params
    self.searchable.url_params
  end

  protected

  def self.nullable_param(params, key)
    params[key].blank? ? nil : params[key]
  end

  def self.day_selected?(params, day)
    params[:days] && params[:days].include?(day.to_s)
  end
end