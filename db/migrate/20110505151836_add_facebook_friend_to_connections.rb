class AddFacebookFriendToConnections < ActiveRecord::Migration
  def self.up
    add_column :connections, :facebook_friend, :boolean
  end

  def self.down
    remove_column :connections, :facebook_friend
  end
end
