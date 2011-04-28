class RemoveFriendshipsTable < ActiveRecord::Migration
  def self.up
    drop_table :friendships
  end

  def self.down
    create_table "friendships", :force => true do |t|
      t.integer  "user_id"
      t.integer  "friend_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
