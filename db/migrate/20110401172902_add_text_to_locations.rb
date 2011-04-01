class AddTextToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :text, :string
  end

  def self.down
    remove_column :locations, :text
  end
end
