class AddLocationToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_known_longitude, :float
    add_column :users, :last_known_latitude, :float
    add_column :users, :last_known_location_datetime, :datetime

  end

  def self.down
    remove_column :users, :last_known_longitude
    remove_column :users, :last_known_latitude
    remove_column :users, :last_known_location_datetime
  end
end
