class Event < ActiveRecord::Base

  validates :name, :presence => true, :length => { :maximum => 60 }
  validates :description, :length => { :maximum => 200 }
  validates :held_on, :presence => true
  validates :cost, :presence => true, :numericality => { :only_integer => true }, :unless => :free?

end
