class CreateFeedTable < ActiveRecord::Migration
  def self.up
    create_table :feed do |t|
      t.integer "user_id"
      t.integer "head_action_id"
      t.integer "index_action_id"
      t.string "reason"
    end
  end

  def self.down
    drop_table :feed
  end
end
