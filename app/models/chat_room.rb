class ChatRoom < ActiveRecord::Base

  belongs_to :location
  has_many :messages
  has_and_belongs_to_many :users

  scope :in_bounds, lambda { |ne_lat, ne_lng, sw_lat, sw_lng|
    includes(:location).merge(Location.in_bounds(ne_lat, ne_lng, sw_lat, sw_lng))
  }

end
