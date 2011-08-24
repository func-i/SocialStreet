class Jobs::Facebook::PostToFriendsFbWall
  @queue = :connections

  def self.perform(from_user_id, to_user_id, hsh)
    # => Load the fb_user and post to their feed using fb_graph
    from_user = User.find(from_user_id)
    to_user = User.find(to_user_id)
    fb_friend = from_user.facebook_user.friends.select{|f| f.identifier.eql?(to_user.fb_uid)}.first if from_user.facebook_user
    fb_friend.feed!(hsh) if from_user.facebook_user.permissions.include?(:publish_stream)
  end
end
