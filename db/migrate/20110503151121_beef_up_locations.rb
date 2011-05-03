class BeefUpLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :user_id, :integer
    add_column :locations, :system, :boolean
    
    add_index :locations, :user_id
    
  end

  def self.down
    remove_column :locations, :user_id
    remove_column :locations, :system
  end
end
