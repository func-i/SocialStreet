class AddBoundsEtcToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :sw_lat, :float
    add_column :locations, :sw_lng, :float
    add_column :locations, :ne_lat, :float
    add_column :locations, :ne_lng, :float
  end

  def self.down
    remove_column :locations, :sw_lat
    remove_column :locations, :sw_lng
    remove_column :locations, :ne_lat
    remove_column :locations, :ne_lng
  end
end
