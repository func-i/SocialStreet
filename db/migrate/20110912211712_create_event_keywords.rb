class CreateEventKeywords < ActiveRecord::Migration
  def self.up
    create_table :event_keywords do |t|
      t.string :name
      t.references :event_type
      t.references :event
      t.timestamps
    end
  end

  def self.down
    drop_table :event_keywords
  end
end
