class RemoveDowCacheFromEvents < ActiveRecord::Migration
  def self.up
    remove_column :events, :held_on_day_of_week
  end

  def self.down
    add_column :events, :held_on_day_of_week, :integer
    add_index "events", "held_on_day_of_week"
  end
end
