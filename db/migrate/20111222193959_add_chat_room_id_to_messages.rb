class AddChatRoomIdToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :chat_room_id, :integer
    add_index :messages, :chat_room_id
  end

  def self.down
    remove_column :messages, :chat_room_id
    remove_index :messages, :chat_room_id
  end
end
