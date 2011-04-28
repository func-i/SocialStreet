class AddFbUidToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :fb_uid, :string
    add_index :users, :fb_uid
  end

  def self.down
    remove_column :users, :fb_uid
  end
end
