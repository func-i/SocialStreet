class AddHeldOnDayOfWeekToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :held_on_day_of_week, :integer
    add_index :events, :held_on_day_of_week
  end

  def self.down
    remove_column :events, :held_on_day_of_week
  end
end
