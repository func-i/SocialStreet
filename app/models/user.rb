class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable

  has_many :authentications
  has_many :rsvps
  has_many :activities
  has_many :comments

  has_many :friendships
  has_many :friends, :through => :friendships
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user


  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :first_name, :last_name

  validates :email, :uniqueness => { :allow_blank => true }

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
