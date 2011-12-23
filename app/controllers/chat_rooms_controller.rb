class ChatRoomsController < ApplicationController

  before_filter :ss_authenticate_user!

  def show
    @chat_room = ChatRoom.find params[:id]
    @chat_room.users << current_user
    render :layout => false
  end

  def leave
    @chat_room = ChatRoom.find params[:id]
    @chat_room.users.delete(current_user)
    render :nothing => true
  end

  

end
