class ConnectionsController < ApplicationController

  before_filter :ss_authenticate_user!, :only => [:import_facebook_friends, :import_friends, :index]

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

  def import_friends   
    Jobs::CreateConnectionsFromFacebook.perform_sync_or_wait_for_async(current_user.id) if current_user
    render :update do |page|
      page.redirect_to(params[:return].blank? ? root_path : params[:return])
    end
  end

  def import_facebook_friends    
    if current_user.fb_friends_imported?
      redirect_to(params[:return] || root_path)
    end
  end


  def facebook_realtime
    
    if request.get?
      # => Get requests from facebook will verify the user subscription

      # => To accept the request you have to respond with the params["hub.challenge"] value as plain/text
      # => TODO: Check to make sure the verify token is for the individual user that the initial subscription was make for.
      if params["hub.mode"].eql?("subscribe")
        user = User.find_by_fb_uid params["hub.verify_token"]       
        render :text=>params["hub.challenge"], :layout=>false
      end
    elsif request.post?

      Resque.enqueue(Jobs::Facebook::ResponseHandler, params)
      render :text=>"ok", :status=>200
    end
  end


end
