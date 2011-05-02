class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable

  has_many :authentications
  has_many :rsvps
  has_many :actions
  has_many :comments
  has_many :events # events this user has created (event.user_id == my.id)
  has_many :search_subscriptions
  
  has_many :rsvp_events, :through => :rsvps, :source => :event, :conditions => "rsvps.status = "

  has_many :connections
  has_many :incoming_connections, :class_name => "Connection", :foreign_key => "to_user_id"
  has_many :connected_users, :through => :connections, :source => :to_user

  has_many :invitations #
  has_many :received_invitations, :class_name => "Invitation", :foreign_key => "to_user_id"

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me,
    :first_name, :last_name, :comment_notification_frequency, :search_subscriptions_attributes, :fb_uid, :facebook_profile_picture_url

  default_value_for :comment_notification_frequency do
    SearchSubscription.frequencies[:immediate]
  end

  accepts_nested_attributes_for :search_subscriptions

  validates :email, :uniqueness => { :allow_blank => true }

  scope :connected_with, lambda {|user|
    includes(:incoming_connections).where("connections.user_id = ?", user.id)
  }
  scope :attending_event, lambda {|event|
    includes(:rsvps).where("rsvps.event_id = ?", event.id)
  }

  # RSVP: event.rsvps.attending.connected_with(me).includes(:user)
  # users = event.attending_users.connected_with(user)
  #user.connected_with(event.attending_users)


  def apply_omniauth(omniauth)
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'], :auth_response => omniauth)
    if omniauth['extra'] && user_info = omniauth['extra']['user_hash']
      self.username = user_info['screen_name'] if !user_info['screen_name'].blank? && self.username.blank?
      if !user_info['name'].blank?
        split = user_info['name'].split
        if self.first_name.blank?
          self.first_name = split.size == 2 ? split.first : user_info['name']
        end
        if self.last_name.blank?
          self.last_name = split.last if split.size == 2
        end
      end
      self.email = user_info['email'] if !user_info['email'].blank? && self.email.blank?
    end
    if omniauth['provider'] == 'facebook' && omniauth['user_info']
      self.facebook_profile_picture_url = omniauth['user_info']['image'] if self.facebook_profile_picture_url.blank?
    elsif omniauth['provider'] == 'twitter' && omniauth['user_info']
      self.twitter_profile_picture_url = omniauth['user_info']['image'] if self.twitter_profile_picture_url.blank?
    end
  end

  def name
    if first_name? || last_name?
      "#{first_name} #{last_name}"
    elsif username?
      username
    else
      "Sir/Madam" # for now, should have more conditions before this
    end
  end

  def avatar_url
    # TODO: check for custom avatar image first, once it is implemented
    facebook_profile_picture_url || twitter_profile_picture_url
  end

  def fb_auth_token
    authentications.first.fb_auth_token
  end

  def editable_by?(user)
    self == user
  end
  
  def password_required?
    # The '&& super' part of the code was in the Railscast but raises an error:
    # super: no superclass method `password_required?' for #<User:0x00000101aca448>
    # Not sure why, maybe Devise no longer has this method?
    (authentications.empty? || !password.blank?) # && super
  end

  
end
