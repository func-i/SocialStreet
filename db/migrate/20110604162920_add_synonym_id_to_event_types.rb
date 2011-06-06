class AddSynonymIdToEventTypes < ActiveRecord::Migration
  def self.up
    add_column :event_types, :synonym_id, :integer
    add_index :event_types, :synonym_id
  end

  def self.down
    remove_column :event_types, :synonym_id
  end
end
