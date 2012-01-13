class ChatRoomsController < ApplicationController

  before_filter :set_redirect
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

  protected

  def set_redirect
    store_redirect(:controller => 'chat_rooms', :params => {:chat_room_id => params[:id]})
  end
end
