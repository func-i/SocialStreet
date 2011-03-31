class Location < ActiveRecord::Base

  geocoded_by :geocodable_address
  after_validation :geocode, :if => :geocodable_address_changed?

  has_many :events

  validates :street,  :length => { :maximum => 100 }
  validates :city,    :length => { :maximum => 30 }
  validates :state,   :length => { :maximum => 30 }
  validates :country, :length => { :maximum => 30 }
  validates :postal,  :length => { :maximum => 10 }

  # Not the most human readable, so only used for geocoding services
  def geocodable_address
    if street? || postal? || (city? && state?)
      [street, city, state, country, postal].join(', ')
    end # otherwise return nil
  end

  def geocodable_address_changed?
    street_changed? || city_changed? || state_changed? || country_changed? || postal_changed?
  end


end
