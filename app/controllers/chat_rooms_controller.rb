class ChatRoomsController < ApplicationController

  before_filter :ss_authenticate_user!

  def show
    @chat_room = ChatRoom.find params[:id]
    render :layout => false
  end

  

end
