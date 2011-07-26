class RenameFeedToFeeds < ActiveRecord::Migration
  def self.up
    rename_table(:feed, :feeds)
  end

  def self.down
    rename_table(:feeds, :feed)
  end
end
