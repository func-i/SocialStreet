class Location < ActiveRecord::Base

  make_searchable :fields => %w{locations.text}

  geocoded_by :geocodable_address
  after_validation :geocode, :if => :should_geocode?

  reverse_geocoded_by :latitude, :longitude do |obj,results|
    if geo = results.first
      obj.city    = geo.city
      obj.postal = geo.postal_code
      obj.country = geo.country_code
      obj.state = geo.state
      obj.street = geo.address.split(',')[0]

      if geo.is_a?(Geocoder::Result::Google)
        if entity = geo.address_components_of_type(:neighborhood).first
          obj.neighborhood = entity['long_name']
        end
        if entity = geo.address_components_of_type(:route).first
          obj.route= entity['long_name']
        end
      end
    end
  end
  after_validation :reverse_geocode, :if => :should_reverse_geocode?

  has_many :searchables
  belongs_to :user

  validates :text,    :length => { :maximum => 200 }
  validates :text,    :presence => true, :if => :needs_text?
  validates :street,  :length => { :maximum => 100 }
  validates :city,    :length => { :maximum => 30 }
  validates :state,   :length => { :maximum => 30 }
  validates :country, :length => { :maximum => 30 }
  validates :postal,  :length => { :maximum => 10 }

  # FIXME: This is incomplete, as it doesnt take into account meridian, and it is untested.
  #        Need to find an example of this implemented from a Geo perspective, to save time and effort. - KV
  # http://silentmatt.com/rectangle-intersection/
  scope :intersecting_bounds, lambda { |ne_lat, ne_lng, sw_lat, sw_lng|
    where("locations.sw_lat < #{ne_lat} AND locations.ne_lat > #{sw_lat}
      AND locations.sw_lng < #{ne_lng} AND locations.ne_lng > #{sw_lng}")
  }

  # Taken from GeoKit / GeoKit Rails bounds logic - KV
  # This is used for the explore page, to find events (points) within a bounds
  scope :in_bounds, lambda { |ne_lat, ne_lng, sw_lat, sw_lng|
    # The lng_sql checks if the bounds crosses the meridian. Taken from GeoKit / GeoKit Rails bounds logic
    lng_sql = sw_lng > ne_lng ? "(locations.longitude<#{ne_lng} OR locations.longitude>#{sw_lng})" : "locations.longitude>#{sw_lng} AND locations.longitude<#{ne_lng}"
    final_sql = "locations.latitude>#{sw_lat} AND locations.latitude<#{ne_lat} AND #{lng_sql}"
    where(final_sql)
  }

  # Search for locations by relevance for user
  scope :searched_by, lambda { |user, query, ne_lat, ne_lng, sw_lat, sw_lng|
    with_keywords(query).in_bounds(ne_lat, ne_lng, sw_lat, sw_lng).
      order("(CASE #{"WHEN locations.user_id = #{user.id} THEN 2" if user} WHEN
        (locations.system IS NOT NULL AND locations.system = true) THEN 1 ELSE 0 END) DESC, locations.updated_at DESC")
  }

  # Not the most human readable, so only used for geocoding services
  def geocodable_address
    if has_geocodable_address?
      [street, city, state, country, postal].join(', ')
    elsif has_geocodable_address_text?
      text
    end # otherwise return nil
  end

  def humanized_address
    if has_geocodable_address?
      "#{street}, #{city}"
    elsif has_geocodable_address_text?
      text
    end # otherwise return nil
  end

  def needs_text?
    !has_geocodable_address? && !geo_located?
  end
  def has_geocodable_address?
    street? || postal? || (city? && state?)
  end
  def has_geocodable_address_text?
    text?
  end

  def geo_located?
    latitude? && longitude?
  end

  # it's not a pin point location, rather a bounding box
  # bounding box = sw_lat/lng and ne lat/lng
  def bounding_box?
    sw_lat? && sw_lng? && ne_lat? && ne_lng?
  end

  # order: ne_lat, ne_lng, sw_lat, sw_lng
  def bounds
    if bounding_box?
      [ne_lat, ne_lng, sw_lat, sw_lng]
    elsif geo_located?
      [latitude, longitude, latitude, longitude] # point represented as a box
    end
  end

  # this code isn't the most optimized, there should ideall be only 4 checks, but there are 8
  #  def intersects_with?(location)
  #    contains?(location.bounds[0])
  #  end
  #
  #  def contains?(lat, lng)
  #    box = bounds
  #    res = lat > box[2] && point.lat < box[0]
  #    if crosses_meridian?
  #      res &= lng < box[1] || lng > box[3]
  #    else
  #      res &= lng < box[1] && lng > box[3]
  #    end
  #  end

  protected

  def geocodable_address_changed?
    text_changed? || street_changed? || city_changed? || state_changed? || country_changed? || postal_changed?
  end

  def should_geocode?
    # only if lat/lng not provided by user/form
    if new_record? && !geo_located?
      return true
    else
      return geocodable_address_changed? && !latitude_changed? && !longitude_changed?
    end
  end

  def should_reverse_geocode?
    if new_record? && !has_geocodable_address?
      return true
    else
      return latitude_changed? || longitude_changed?
    end
  end

end
