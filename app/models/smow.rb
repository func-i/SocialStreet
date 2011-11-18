class Smow < ActiveRecord::Base
  belongs_to :event

  validates :title, :presence => true
  validates :what_text, :presence => true
  validates :when_text, :presence => true
  validates :top_image_url, :presence => true
  validates :bottom_image_url, :presence => true

end
