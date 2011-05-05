class Authentication < ActiveRecord::Base

  serialize :auth_response, Hash

  belongs_to :user

  after_create :set_fb_uid
  after_create :load_facebook_friends

  scope :facebook, where(:provider => "facebook")

  def facebook?
    provider == "facebook"
  end

  def fb_auth_token
    auth_response["credentials"]["token"] if facebook?
  end

  protected

  def set_fb_uid
    if facebook? && user && user.fb_uid.blank?
      user.update_attributes :fb_uid => self.uid
    end
  end

  def load_facebook_friends
    if facebook?
      fb = FbGraph::User.new('me', :access_token => fb_auth_token)
      fb.friends.each do |friend|
        u = User.find_by_fb_uid(friend.identifier)
        u ||= User.create({
            :fb_uid => friend.identifier,
            :first_name => friend.first_name || friend.name.to_s.split.first,
            :last_name => friend.last_name || friend.name.to_s.split.last,
            :facebook_profile_picture_url => friend.picture
          })
        
        c = user.connections.to_user(u).first
        c ||= user.connections.create({:to_user => u, :facebook_friend => true})
        
      end
    end
  end

end

