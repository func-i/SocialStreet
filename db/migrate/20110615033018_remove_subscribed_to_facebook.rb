class RemoveSubscribedToFacebook < ActiveRecord::Migration
  def self.up
    remove_column :users, :subscribed_to_fb_realtime
  end

  def self.down
    add_column :users, :subscribed_to_fb_realtime, :boolean, :default => false
  end
end
