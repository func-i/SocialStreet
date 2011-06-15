class SSFB::Tools

  def self.subscribe_to_facebook_realtime
    app = FbGraph::Application.new(FACEBOOK_APP_ID, :secret => FACEBOOK_APP_SECRET)
    app.subscribe!(
      :object => "user",
      :fields => "friends,permissions",
      :callback_url => "http://99.232.169.50:3000/connections/facebook_realtime",
      :verify_token => user.facebook_access_token
    ) if facebook_access_token# && Rails.env.eql?("production")
  end 


end
