class CreateChatRooms < ActiveRecord::Migration
  def self.up
    create_table :chat_rooms do |t|
      t.string :name
      t.integer :location_id
      t.timestamps
    end
  end

  def self.down
    drop_table :chat_rooms
  end
end
