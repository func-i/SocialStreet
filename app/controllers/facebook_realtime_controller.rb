class FacebookRealtimeController < ApplicationController
  def update
    if request.get?
      # => Get requests from facebook will verify the user subscription

      # => To accept the request you have to respond with the params["hub.challenge"] value as plain/text
      # => TODO: Check to make sure the verify token is for the individual user that the initial subscription was make for.
      if params["hub.mode"].eql?("subscribe")
        user = User.find_by_fb_uid params["hub.verify_token"]

        # => TODO:  Add the db field users.subscribe_to_facebook
        user.update_attribute("subscribed_to_fb_realtime", true) if user
        render :text=>params["hub.challenge"], :layout=>false
      end
    elsif request.post?
      Resque.enqueue(Jobs::Facebook::ResponseHandler, params)
      render :text=>"ok", :status=>200
    end
  end
end