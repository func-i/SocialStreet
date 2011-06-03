class AddNameFlagToSearchableEventTypes < ActiveRecord::Migration
  def self.up
    add_column :searchable_event_types, :name, :string
  end

  def self.down
    remove_column :searchable_event_types, :name
  end
end
