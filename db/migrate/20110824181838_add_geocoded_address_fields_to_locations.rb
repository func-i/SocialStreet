class AddGeocodedAddressFieldsToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :geocoded_address, :string
  end

  def self.down
    remove_column :locations, :geocoded_address
  end
end
