class MessagesController < ApplicationController

  def create
    @chat_room = ChatRoom.find params[:chat_room_id]
    @message = @chat_room.messages.create!(params[:message])
  end

end
