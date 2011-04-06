class AddMissingIndiciesToActivities < ActiveRecord::Migration
  def self.up
    add_index :activities, [:reference_type, :reference_id]
  end

  def self.down
    remove_index :activities, [:reference_type, :reference_id]
  end
end
