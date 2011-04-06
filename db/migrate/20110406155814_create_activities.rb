class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.belongs_to :event
      t.belongs_to :user
      t.belongs_to :reference, :polymorphic => true
      t.string :activity_type
      t.datetime :occurred_at
      t.timestamps
    end

    add_index :activities, :event_id
    add_index :activities, :user_id
  end

  def self.down
    drop_table :activities
  end
end
