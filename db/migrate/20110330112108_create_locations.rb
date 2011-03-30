class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.string :street
      t.string :city
      t.string :state
      t.string :country
      t.string :postal
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
    add_index :locations, [:latitude, :longitude]
  end

  def self.down
    drop_table :locations
  end
end
