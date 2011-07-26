class RenameTmpFeedItemToFeed < ActiveRecord::Migration
  def self.up
    drop_table :tmp_feed_items
  end

  def self.down
  end
end
