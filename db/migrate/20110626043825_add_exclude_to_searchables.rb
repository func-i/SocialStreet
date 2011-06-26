class AddExcludeToSearchables < ActiveRecord::Migration
  def self.up
    add_column :searchables, :ignored, :boolean, :default => false
  end

  def self.down
    remove_column :searchables, :ignored
  end
end
