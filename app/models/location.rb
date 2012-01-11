class Location < ActiveRecord::Base
  has_many :events

  validates :text,    :length => { :maximum => 200 }
  #validates :text,    :presence => {:message => "^ Where? can't be blank"}, :if => :needs_text?
  validates :street,  :length => { :maximum => 100 }
  validates :city,    :length => { :maximum => 30 }
  validates :state,   :length => { :maximum => 30 }
  validates :country, :length => { :maximum => 30 }
  validates :postal,  :length => { :maximum => 10 }

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


  scope :in_bounds, lambda { |ne_lat, ne_lng, sw_lat, sw_lng|
    # The lng_sql checks if the bounds crosses the meridian. Taken from GeoKit / GeoKit Rails bounds logic
    lng_sql = sw_lng > ne_lng ? "(locations.longitude<#{ne_lng} AND locations.longitude>#{sw_lng})" : "locations.longitude>#{sw_lng} AND locations.longitude<#{ne_lng}"
    final_sql = "locations.latitude>#{sw_lat} AND locations.latitude<#{ne_lat} AND #{lng_sql}"
    where(final_sql)
  }

  def geocoded_address=(a)
    a_components = a.split(',')
    #HACKITY HACK HACK HACKITY HACK
    self.street = a_components[0] if a_components.length > 0
    self.city = a_components[1] if a_components.length > 1
    self.state = a_components[2] if a_components.length > 2
    self.country = a_components[3] if a_components.length > 3
    self.postal = a_components[4] if a_components.length > 4
  end

  def geocodable_address
    if has_geocodable_address?
      [street, city, state, country, postal].join(', ')
    elsif has_geocodable_address_text?
      text
    end # otherwise return nil
  end

  def short_address_as_sentence
    "#{street}, #{city}"
  end

  def as_sentence
    "#{(text + "\n") if text}#{street}, #{city}, #{state}"
  end

  def geo_located?
    latitude? && longitude?
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
