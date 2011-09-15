class RenameRsvps < ActiveRecord::Migration
  def self.up
    drop_table :event_rsvp
    create_table :event_rsvps do |t|
      t.references :user, :null => false
      t.references :invitor
      t.references :event, :null => false
      t.boolean :organizer, :default => false
      t.boolean :posted_to_facebook, :default => false
      t.string :status
      t.timestamps
    end
  end

  def self.down
    drop_table :event_rsvps
    create_table :event_rsvp do |t|
      t.references :user, :null => false
      t.references :invitor
      t.references :event, :null => false
      t.boolean :organizer, :default => false
      t.boolean :posted_to_facebook, :default => false
      t.string :status
      t.timestamps
    end
  end
end
