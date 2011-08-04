class AddComponentsToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :neighborhood, :string
    add_column :locations, :route, :string
  end

  def self.down
    remove_column :locations, :neighborhood
    remove_column :locations, :route
  end
end
