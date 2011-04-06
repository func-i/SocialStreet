class FixRsvps < ActiveRecord::Migration
  def self.up
    remove_column :rsvps, :response
    add_column :rsvps, :status, :string
    add_index :rsvps, :user_id
    add_index :rsvps, :event_id
  end

  def self.down
    remove_column :rsvps, :status
    add_column :rsvps, :response, :string
    remove_index :rsvps, :user_id
    remove_index :rsvps, :event_id
  end
end
