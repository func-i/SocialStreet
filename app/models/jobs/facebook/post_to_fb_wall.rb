class Jobs::Facebook::PostToFbWall
  @queue = :connections

  def self.perform(user_id, hsh)
    # => Load the fb_user and post to their feed using fb_graph
    user = User.find(user_id)
    user.facebook_user.feed!(
      :message => hsh["message"],
      :link => hsh["link"]
    ) if user.facebook_user && user.facebook_user.permissions.include?(:publish_stream)
  end

end
