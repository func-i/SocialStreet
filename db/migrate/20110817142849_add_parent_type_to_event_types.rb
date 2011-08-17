class AddParentTypeToEventTypes < ActiveRecord::Migration
  def self.up
    add_column :event_types, :parent_id, :integer
  end

  def self.down
    remove_column :event_types, :parent_id
  end
end
