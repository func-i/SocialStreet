class RemoveSearchFilterIdFromComments < ActiveRecord::Migration
  def self.up
    remove_column :comments, :search_filter_id
  end

  def self.down
    add_column :comments, :search_filter_id, :integer
    add_index :comments, :search_filter_id
  end
end
