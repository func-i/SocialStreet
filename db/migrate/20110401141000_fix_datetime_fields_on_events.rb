class FixDatetimeFieldsOnEvents < ActiveRecord::Migration

  # and some other stuff

  def self.up
    add_column :events, :finishes_at, :datetime
    rename_column :events, :held_on, :starts_at

    add_index :events, [:starts_at, :finishes_at]

    add_index "events", ["latitude", "longitude"]
  end

  def self.down
    remove_index "events", ["latitude", "longitude"]
    remove_index :events, [:starts_at, :finishes_at]

    rename_column :events, :starts_at, :held_on
    remove_column :events, :finishes_at
  end
end
