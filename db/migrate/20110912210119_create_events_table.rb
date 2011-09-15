class CreateEventsTable < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :name
      t.text :description
      t.datetime :start_date
      t.datetime :end_date
      t.references :location
      t.references :user
      t.boolean :canceled, :default => false
      t.boolean :promoted, :default => false

      t.timestamps
    end

    add_index :events, :user_id
    add_index :events, :location_id
  end
  
  def self.down
    drop_table :events
  end
end
