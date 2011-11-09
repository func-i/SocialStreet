class CreateEventGroups < ActiveRecord::Migration
  def self.up
    create_table :event_groups do |t|
      t.integer :event_id
      t.integer :group_id

      t.timestamps
    end
  end

  def self.down
    drop_table :event_groups
  end
end
