class RenameIsWaiting < ActiveRecord::Migration
  def self.up
    rename_column :rsvps, :isWaiting, :waiting
  end

  def self.down
    rename_column :rsvps, :waiting, :isWaiting
  end
end
