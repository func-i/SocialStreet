class AddSearchFilterIdToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :search_filter_id, :integer
    add_index :comments, :search_filter_id
  end

  def self.down
    remove_column :comments, :search_filter_id
  end
end
