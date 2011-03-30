class Event < ActiveRecord::Base

  geocoded_by :location_address

  belongs_to :location
  accepts_nested_attributes_for :location

  before_save :cache_lat_lng

  validates :name, :presence => true, :length => { :maximum => 60 }
  validates :description, :length => { :maximum => 200 }
  validates :held_on, :presence => true
  validates :cost, :presence => true, :numericality => { :only_integer => true }, :unless => :free?

  def location_address
    location.geocodable_address if location
  end

  protected

  def cache_lat_lng
    if location && !location.new_record?
      self.latitude = location.latitude
      self.longitude = location.longitude
    end
  end


end
