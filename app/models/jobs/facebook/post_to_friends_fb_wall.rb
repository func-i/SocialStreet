class Jobs::Facebook::PostToFriendsFbWall
  @queue = :connections

  def self.perform(from_user_id, to_user_id, hsh)
    # => Load the fb_user and post to their feed using fb_graph
    from_user = User.find(from_user_id)
    to_user = User.find(to_user_id)

    fb_user = from_user.facebook_user
    fb_friend = fb_user.friends.select{|f| f.identifier.eql?(to_user.fb_uid)}.first if fb_user
    fb_friend.feed!(hsh.merge(:access_token => from_user.fb_auth_token)) if fb_user.permissions.include?(:publish_stream)
  end
end
