class InvitationsController < ApplicationController

  def new
    @connections = current_user.connections.most_relevant_first.limit(30).all
  end

end
