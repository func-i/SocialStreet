class CreateChatRoomUsers < ActiveRecord::Migration
  def self.up
    create_table :chat_rooms_users, :id => false do |t|
      t.integer :chat_room_id
      t.integer :user_id
    end
  end

  def self.down
    drop_table :chat_room_users
  end
end
