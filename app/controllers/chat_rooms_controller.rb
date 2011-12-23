class ChatRoomsController < ApplicationController

  before_filter :ss_authenticate_user!

  def show
    @chat_room = ChatRoom.find params[:id]

    r = Redis.new
    @chat_members = User.find r.smembers("cr_user_list_#{@chat_room.id}")
    r.quit

    render :layout => false
  end

  def join
    @chat_room = ChatRoom.find params[:id]

    r = Redis.new
    r.sadd "cr_user_list_#{@chat_room.id}", current_user.id
    r.quit
  end

  def leave
    @chat_room = ChatRoom.find params[:id]       

    r = Redis.new
    r.srem "cr_user_list_#{@chat_room.id}", current_user.id
    r.quit
  end
end
