class Message < ActiveRecord::Base
  belongs_to :chat_room
  belongs_to :user
  
  attr_accessible :content, :user_id
end
