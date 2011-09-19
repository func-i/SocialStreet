class AddEmailToEventRsvps < ActiveRecord::Migration
  def self.up
    add_column :event_rsvps, :email, :string
  end

  def self.down
    remove_column :event_rsvps, :email
  end
end
