class AddIndexesToAllTables < ActiveRecord::Migration
  def self.up
    add_index :event_types, :parent_id
    add_index :event_types, :synonym_id

    add_index :event_rsvps, :user_id
    add_index :event_rsvps, :invitor_id
    add_index :event_rsvps, :event_id

    add_index :event_keywords, :event_id
    add_index :event_keywords, :event_type_id

    add_index :connections, :user_id
    add_index :connections, :to_user_id

    add_index :comments, :user_id
    add_index :comments, :event_id

    add_index :authentications, :user_id

  end

  def self.down
    remove_index :event_types, :parent_id
    remove_index :event_types, :synonym_id

    remove_index :event_rsvps, :user_id
    remove_index :event_rsvps, :invitor_id
    remove_index :event_rsvps, :event_id

    remove_index :event_keywords, :event_id
    remove_index :event_keywords, :event_type_id

    remove_index :connections, :user_id
    remove_index :connections, :to_user_id

    remove_index :comments, :user_id
    remove_index :comments, :event_id

    remove_index :authentications, :user_id
  end
end
