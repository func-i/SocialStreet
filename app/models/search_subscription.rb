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

  default_value_for :frequency, @@frequencies[:immediate]

  scope :with_event_types_or_null, lambda{ |event_type_ids|
    joins("LEFT OUTER JOIN searchable_event_types
            ON searchable_event_types.searchable_id = search_subscriptions.searchable_id").
      where("searchable_event_types.event_type_id IN (#{event_type_ids}
            OR searchable_event_types.event_type_id IS NULL")
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

  scope :daily, where(:frequency => @@frequencies[:daily])
  scope :weekly, where(:frequency => @@frequencies[:weekly])

  def matches_date_ranges?(date_ranges)
    searchable.searchable_date_ranges.blank? || !!searchable.searchable_date_ranges.detect { |dr| dr.overlapping_with? date_ranges }
  end

  def self.matching_search_comment(comment)
    matching_searchable(comment.searchable, comment.body)
  end

  def self.matching_searchable(searchable, text_to_match_keywords = nil)
    bounds = searchable.lat_lng_bounds

    searchables = Searchable.with_only_subscriptions.
        with_keywords_that_match_text_or_keywords(text_to_match_keywords, searchable).
        intersecting_bounds(bounds[0],bounds[1],bounds[2],bounds[3]).
        all.select { |s| s.search_subscription.matches_date_ranges?(searchable.searchable_date_ranges.all)}

    searchables.collect &:search_subscription
  end

  def self.matching_event(event)
    text = event.description + " " + event.name

    matching_searchable(event.searchable, text)
  end

  def self.new_from_params(params)
    searchable = Searchable.new_from_params(params)
    SearchSubscription.new(:searchable => searchable, :name => searchable.title_for_searchable)
  end

  def url_params
    self.searchable.url_params
  end

  def immediate?
    frequency == @@frequencies[:immediate]
  end
  def not_immediate?
    ![@@frequencies[:immediate], @@frequencies[:none]].include? frequency
  end

  protected

  def self.nullable_param(params, key)
    params[key].blank? ? nil : params[key]
  end

  def self.day_selected?(params, day)
    params[:days] && params[:days].include?(day.to_s)
  end
end