class RemoveEventTypeIdFromEvents < ActiveRecord::Migration
  def self.up
    remove_column :events, :event_type_id
  end

  def self.down
    add_column :events, :event_type_id, :integer
    add_index :events, :event_type_id
  end
end
