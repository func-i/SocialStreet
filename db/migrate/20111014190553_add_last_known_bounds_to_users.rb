class AddLastKnownBoundsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_known_bounds_sw_lat, :integer
    add_column :users, :last_known_bounds_sw_lng, :integer
    add_column :users, :last_known_bounds_ne_lat, :integer
    add_column :users, :last_known_bounds_ne_lng, :integer
  end

  def self.down
    remove_column :users, :last_known_bounds_sw_lat
    remove_column :users, :last_known_bounds_sw_lng
    remove_column :users, :last_known_bounds_ne_lat
    remove_column :users, :last_known_bounds_ne_lng
  end
end
