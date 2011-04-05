class Location < ActiveRecord::Base

  geocoded_by :geocodable_address
  after_validation :geocode, :if => :geocodable_address_changed?

  has_many :events

  validates :text,    :length => { :maximum => 200 }
  validates :text,    :presence => true, :unless => :has_geocodable_address?
  validates :street,  :length => { :maximum => 100 }
  validates :city,    :length => { :maximum => 30 }
  validates :state,   :length => { :maximum => 30 }
  validates :country, :length => { :maximum => 30 }
  validates :postal,  :length => { :maximum => 10 }

  # Not the most human readable, so only used for geocoding services
  def geocodable_address
    if has_geocodable_address?
      [street, city, state, country, postal].join(', ')
    elsif has_geocodable_address_text?
      text
    end # otherwise return nil
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

  protected

  def geocodable_address_changed?
    text_changed? || street_changed? || city_changed? || state_changed? || country_changed? || postal_changed?
  end



end
