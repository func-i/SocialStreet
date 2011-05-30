class CreateTmpFeedItemTable < ActiveRecord::Migration
  def self.up
    create_table :tmp_feed_items do |t|
      t.integer :action_id
      t.integer :event_id
      t.integer :user_id
      t.string :feed_type
      t.string :inserted_because
      t.datetime :last_touched

      t.timestamps
    end
  end

  def self.down
    drop_table :tmp_feed_items
  end
end
