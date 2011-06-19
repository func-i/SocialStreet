class AddFbFriendsImportedBooleanToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :fb_friends_imported, :boolean, :default => false
  end

  def self.down
    remove_column :users, :fb_friends_imported
  end
end
