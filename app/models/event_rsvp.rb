class EventRsvp < ActiveRecord::Base
  @@statuses = {
    :attending => 'Attending',
    :not_attending => 'Not Attending',
    :maybe_attending => 'Maybe',
    :invited => 'Invited'
  }.freeze
  cattr_accessor :statuses

  belongs_to :user
  belongs_to :event
  belongs_to :invitor, :class_name => "User"

  has_many :event_prompt_answers
  has_many :event_prompts, :through => :event_prompt_answers

  validates :event_id, :uniqueness => {:scope => [:user_id, :email] }

  scope :for_event, lambda {|event| where(:event_id => event.id) }
  scope :by_user, lambda {|user| where(:user_id => user.id) }

  scope :attending, where(:status => @@statuses[:attending])
  scope :maybe_attending, where(:status => @@statuses[:maybe_attending])
  scope :attending_or_maybe_attending, where("event_rsvps.status IN (?)", @@statuses.except(:not_attending).except(:invited).values)
  scope :organizers, where(:organizer => true)

  after_create :send_rsvp_email

  protected

  def send_rsvp_email
    if self.user && self.user != self.event.user && status != @@statuses[:invited]
      mail = UserMailer.event_rsvp_created(self.event, self)
      mail.deliver
    end
  end
end
