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

end
