class Rsvp < ActiveRecord::Base

  
  @@statuses = {
    :attending => 'Attending',
    :not_attending => 'Not Attending',
    :maybe_attending => 'Maybe Attending'
  }
  
  cattr_accessor :statuses

  belongs_to :user

  validates :status, :inclusion => { :in => Rsvp.statuses.values }
  validates :event_id, :uniqueness => {:scope => [:user_id] }

  scope :for_event, lambda {|event| where(:event_id => event.id) }
  scope :by_user, lambda {|user| where(:user_id => user.id) }
  scope :attending, where(:status => @@statuses[:attending])
  
end
