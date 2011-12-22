class Message < ActiveRecord::Base
  belongs_to :chat_room
  
  attr_accessible :content
end
