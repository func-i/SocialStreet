class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable

  mount_uploader :photo, UserPhotoUploader

  make_searchable :fields => %w{users.first_name users.last_name users.email}

  has_many :authentications
  has_many :rsvps
  has_many :feedbacks, :through => :rsvps
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
  attr_accessible :username, :email, :gender, :location, :name, :password, :password_confirmation, :remember_me, :photo,
    :first_name, :last_name, :comment_notification_frequency, :search_subscriptions_attributes, :fb_uid, :facebook_profile_picture_url,
    :tncs_accepted

  attr_accessor :name

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
  scope :has_signed_in, where("sign_in_count > 0")

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
      self.gender = user_info['gender'] if !user_info['gender'].blank? && self.gender.blank?
      self.location = user_info['location']['name'] if !user_info['location'].blank? && !user_info['location']['name'].blank? && self.location.blank?
    end

    if omniauth['provider'] == 'facebook' && omniauth['user_info']
      self.facebook_profile_picture_url = omniauth['user_info']['image'] if self.facebook_profile_picture_url.blank?
    elsif omniauth['provider'] == 'twitter' && omniauth['user_info']
      self.twitter_profile_picture_url = omniauth['user_info']['image'] if self.twitter_profile_picture_url.blank?
    end
  end

  def update_users_location(latitude, longitude)
    self.last_known_latitude = latitude
    self.last_known_longitude = longitude
    self.last_known_location_datetime = Time.zone.now
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

  def name=(n)
    names = n.split( );

    self.first_name = names[0]

    if(names.length > 1)
      self.last_name = names[1...names.length].join(' ')
    else
      self.last_name = ""
    end
  end

  def can_friend?(user)
    return false if(self == user)

    connection = self.connections.to_user(user).first
    !(connection && connection.facebook_friend?)
  end

  def avatar_url
    # TODO: check for custom avatar image first, once it is implemented
    if photo?
      photo.thumb.url
    else
      facebook_profile_picture_url.gsub(facebook_profile_picture_url[facebook_profile_picture_url.rindex('/')+1..facebook_profile_picture_url.length], "picture?type=large") if facebook_profile_picture_url
    end
  end

  def fb_auth_token
    authentications.first.fb_auth_token unless authentications.facebook.empty?
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

  def facebook_user
    # => Load the FB user through fb_graph if there is an access_token
    FbGraph::User.me(fb_auth_token) if fb_auth_token
    #FbGraph::User.new(:access_token => fb_auth_token) if fb_auth_token
  end

  def post_to_facebook_wall(args = {})
    Resque.enqueue_in(1.minutes, Jobs::Facebook::PostToFbWall, self.id, args) if facebook_user && facebook_user.permissions.include?(:publish_stream) && !args[:message].blank?
  end

  def rsvp_for_event(event)
    rsvps.for_event(event).first
  end
  
end
