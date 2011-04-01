class CreateEventTypes < ActiveRecord::Migration
  def self.up
    create_table :event_types do |t|
      t.string :name

      t.timestamps
    end

    add_index :event_types, :name

    add_column :events, :event_type_id, :integer
    add_index :events, :event_type_id
  end

  def self.down
    drop_table :event_types
    remove_column :events, :event_type_id
  end
end
