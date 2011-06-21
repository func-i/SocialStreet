class AddPostedToFacebookToRsvps < ActiveRecord::Migration
  def self.up
    add_column :rsvps, :posted_to_facebook, :boolean, :default => false
  end

  def self.down
    remove_column :rsvps, :posted_to_facebook
  end
end
