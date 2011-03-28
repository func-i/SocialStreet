class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :name
      t.text :description
      t.datetime :held_on
      t.integer :cost
      t.boolean :free

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
