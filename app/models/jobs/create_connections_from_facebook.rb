# Create the initial connections via facebook
class Jobs::CreateConnectionsFromFacebook

  @queue = :connections

  def self.perform(user_id)
    user = User.find(user_id)
    
    fb = FbGraph::User.new('me', :access_token => user.fb_auth_token)
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