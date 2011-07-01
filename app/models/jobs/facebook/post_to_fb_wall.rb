class Jobs::Facebook::PostToFbWall
  @queue = :connections

  def self.perform(user_id, hsh)
    # => Load the fb_user and post to their feed using fb_graph
    User.find(user_id).facebook_user.feed!(
      :message => hsh["message"],
      :link => hsh["link"]
    )
  end

end
