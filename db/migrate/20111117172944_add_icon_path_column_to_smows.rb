class AddIconPathColumnToSmows < ActiveRecord::Migration
  def self.up
    add_column :smows, :icon_path, :string
  end

  def self.down
    remove_column :smows, :icon_path
  end
end
