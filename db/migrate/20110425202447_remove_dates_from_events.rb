class RemoveDatesFromEvents < ActiveRecord::Migration
  def self.up
    remove_column :events, :starts_at
    remove_column :events, :finishes_at
  end

  def self.down
    add_column :events, :starts_at, :datetime
    add_column :events, :finishes_at, :datetime
  end
end
