class ConnectionsController < ApplicationController

  # assume ajax / json for now (it's bad practice but this is prototype code) - KV
  def index
    @connections = current_user.connections.with_keywords(params[:query]).most_relevant_first.limit(10).all
    render :json => @connections.collect {|c| {
        :id => c.to_user.id,
        :name => c.to_user.name,
        :avatar_url => c.to_user.avatar_url
      }
    }
  end

  def facebook_realtime
    
    if request.get?
      # => Get requests from facebook will verify the user subscription

      # => To accept the request you have to respond with the params["hub.challenge"] value as plain/text
      # => TODO: Check to make sure the verify token is for the individual user that the initial subscription was make for.
      if params["hub.mode"].eql?("subscribe")
        user = User.find_by_fb_uid params["hub.verify_token"]

        # => TODO:  Add the db field users.subscribe_to_facebook
        user.update_attribute("subscribed_to_facebook", true) if user
        render :text=>params["hub.challenge"], :layout=>false
      end
    elsif request.post?
      # => Post requests from facebook will update the subscription information.
      # => Post is sent as json.  Read and parse jason request.
      json_post = JSON.parse(params[])

    end
  end


end
