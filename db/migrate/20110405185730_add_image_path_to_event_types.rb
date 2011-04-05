class AddImagePathToEventTypes < ActiveRecord::Migration
  def self.up
    add_column :event_types, :image_path, :string
  end

  def self.down
    remove_column :event_types, :image_path
  end
end
