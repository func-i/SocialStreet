class AddImageUrlsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_profile_picture_url, :string
    add_column :users, :twitter_profile_picture_url, :string
  end

  def self.down
    remove_column :users, :twitter_profile_picture_url
    remove_column :users, :facebook_profile_picture_url
  end
end
