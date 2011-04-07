class AddActivityIdToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :activity_id, :integer
    add_index :events, :activity_id
  end

  def self.down
    remove_column :events, :activity_id
  end
end
