class AddTitleToSmow < ActiveRecord::Migration
  def self.up
    add_column :smows, :title, :string
  end

  def self.down
    remove_column :smows, :title
  end
end
