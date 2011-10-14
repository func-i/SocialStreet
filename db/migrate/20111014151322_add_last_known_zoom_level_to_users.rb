class AddLastKnownZoomLevelToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_known_zoom_level, :integer
  end

  def self.down
    remove_column :users, :last_known_zoom_level
  end
end
