class CreateSearchableEventTypes < ActiveRecord::Migration
  def self.up
    create_table :searchable_event_types do |t|
      t.belongs_to :searchable
      t.belongs_to :event_type
      t.timestamps
    end
    add_index :searchable_event_types, :searchable_id
    add_index :searchable_event_types, :event_type_id
  end

  def self.down
    drop_table :searchable_event_types
  end
end
