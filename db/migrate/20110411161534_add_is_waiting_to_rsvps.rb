class AddIsWaitingToRsvps < ActiveRecord::Migration
  def self.up
    add_column :rsvps, :isWaiting, :boolean
  end

  def self.down
    remove_column :rsvps, :isWaiting
  end
end
