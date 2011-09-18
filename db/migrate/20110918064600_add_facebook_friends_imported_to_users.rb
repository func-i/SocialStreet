class AddFacebookFriendsImportedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_friends_imports, :boolean
  end

  def self.down
    remove_column :users, :facebook_friends_imports
  end
end
