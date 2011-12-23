class ChatRoomsController < ApplicationController

  before_filter :ss_authenticate_user!

  def show
    @chat_room = ChatRoom.find params[:id]    
    render :layout => false
  end

  def join
    @chat_room = ChatRoom.find params[:id]
  end

  def leave
    @chat_room = ChatRoom.find params[:id]       
  end

  

end
