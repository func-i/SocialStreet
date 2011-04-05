class Rsvp < ActiveRecord::Base

  belongs_to :user

  validates :response, :presence => true, :inclusion => { :in => ['Attending', 'Not Attending', 'Maybe Attending'] }

  scope :for_event, lambda {|event| where(:event_id => event.id) }
  scope :by_user, lambda {|user| where(:user_id => user.id) }

end
