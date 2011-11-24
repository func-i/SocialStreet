class AddBottomTextToSmows < ActiveRecord::Migration
  def self.up
    add_column :smows, :bottom_text, :string
  end

  def self.down
    remove_column :smows, :bottom_text
  end
end
