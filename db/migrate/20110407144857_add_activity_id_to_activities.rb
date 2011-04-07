class AddActivityIdToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :activity_id, :integer
    add_index :activities, :activity_id
  end

  def self.down
    remove_column :activities, :activity_id
  end
end
