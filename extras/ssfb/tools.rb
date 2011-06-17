class Ssfb::Tools

  def self.subscribe_to_facebook_realtime
    app = FbGraph::Application.new(FACEBOOK_APP_ID, :secret => FACEBOOK_APP_SECRET)
    app.subscribe!(
      :object => "user",
      :fields => "friends",
      :callback_url => "http://staging.socialstreet.com/connections/facebook_realtime",
      :verify_token => '1234'
    )
  end 

end
