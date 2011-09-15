class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.float    "latitude"
      t.float    "longitude"

      t.string   "street"
      t.string   "city"
      t.string   "state"
      t.string   "country"
      t.string   "postal"
      t.string   "text"
      t.string   "neighborhood"
      t.string   "route"
      t.string   "geocoded_address"

      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end
