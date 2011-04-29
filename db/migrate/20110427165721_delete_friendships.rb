class DeleteFriendships < ActiveRecord::Migration
  def self.up
  	drop_table :friendships
  end

  def self.down
    create_table :friendships do |t|
      t.integer :user_id
      t.integer :friend_id

      t.timestamps
    end
  end
end
