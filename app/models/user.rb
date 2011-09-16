class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable

  has_many :events
  
  has_many :event_rsvps #All rsvps that are for you (invitations/attending/not_attending...)
  has_many :invitations_created, :class_name => "EventRsvp", :foreign_key => "invitor_id" #Invitations we create

  has_many :comments

  has_many :authentications
  has_many :connections
  has_many :incoming_connections, :class_name => "Connection", :foreign_key => "to_user_id"
  has_many :connected_users, :through => :connections, :source => :to_user


  validates :email, :uniqueness => { :allow_blank => true }

  def name
    if first_name? || last_name?
      "#{first_name} #{last_name}"
    elsif username?
      username
    else
      "Sir/Madam" # for now, should have more conditions before this
    end
  end

  def avatar_url(options={})
    self.facebook_profile_picture_url.gsub(facebook_profile_picture_url[facebook_profile_picture_url.rindex('/')+1..facebook_profile_picture_url.length], "picture?type=#{options[:fb_size] || 'square'}") if facebook_profile_picture_url
  end


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
    
    self.facebook_profile_picture_url = omniauth['user_info']['image'] if omniauth['user_info'] && self.facebook_profile_picture_url.blank?
    
  end




end
