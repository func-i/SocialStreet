class AddSubscribedToFbRealtimeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :subscribed_to_fb_realtime, :boolean, :default=>false
  end

  def self.down
    remove_column :users, :subscribed_to_fb_realtime
  end
end
