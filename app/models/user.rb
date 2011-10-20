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

  scope :matching_keyword, lambda{ |keyword|
    where("users.last_name ~* ? OR users.first_name ~* ?", keyword, keyword)
  }

  scope :order_by_rank_to_user, lambda{ |user|
    return unless user
    joins("LEFT OUTER JOIN connections ON users.id = connections.to_user_id AND connections.user_id = #{user.id}").order("connections.rank ASC NULLS LAST")
  }

  scope :attending_event, lambda{|event|
    joins(:event_rsvps).where("event_rsvps.event_id = #{event.id}").merge(EventRsvp.attending_or_maybe_attending)
  }

  scope :excluding, lambda{|user| 
    return unless user
    where("users.id <> #{user.id}")    
  }


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

  def fb_auth_token
    authentications.first.fb_auth_token unless authentications.facebook.empty?
  end

  def facebook_user
    myToken = fb_auth_token
    # => Load the FB user through fb_graph if there is an access_token
    FbGraph::User.me(myToken) if myToken
  end

  def post_to_facebook_wall(args = {})
    Resque.enqueue_in(10.minutes, Jobs::Facebook::PostToFbWall, self.id, args) if facebook_user && facebook_user.permissions.include?(:publish_stream) && !args[:message].blank?
  end


  def update_users_location(latitude, longitude, zoom_level, sw_lat, sw_lng, ne_lat, ne_lng)
    self.last_known_latitude = latitude if latitude
    self.last_known_longitude = longitude if longitude
    self.last_known_zoom_level = zoom_level if zoom_level
    self.last_known_bounds_sw_lat = sw_lat
    self.last_known_bounds_sw_lng = sw_lng
    self.last_known_bounds_ne_lat = ne_lat
    self.last_known_bounds_ne_lng = ne_lng
    self.last_known_location_datetime = Time.zone.now
  end


  def attending?(event)
    return self.event_rsvps.for_event(event).count > 0
  end

  def apply_omniauth(omniauth)
    if self.first_sign_in_date.blank?
      self.first_sign_in_date = Time.now

      Resque.enqueue(Jobs::Email::EmailUserWelcomeNotice, self.id)

      #      if params[:facebook] == '1'
      post_to_facebook_wall(
        :picture => 'http://www.socialstreet.com/images/app_icon_facebook.png',
        :link => "http://www.socialstreet.com/",
        :name => "SocialStreet.com",
        :caption => "Explore real life!",
        :description => 'SocialStreet\'s mission is to make it easy to discover friends that enjoy the same things as you! By attending and organizing "StreetMeets", you are sure to discover that you are surrounded by people just like you!',
        :message => "I just joined SocialStreet!",
        :type => "link"
      )
      #      end
    end

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
