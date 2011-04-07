class ChangeAdministratorToBoolean < ActiveRecord::Migration
  def self.up
    remove_column :rsvps, :administrator
    add_column :rsvps, :administrator, :boolean, :default => false
  end

  def self.down
    remove_column :rsvps, :administrator
    add_column :rsvps, :administrator, :integer, :default => 0
  end
end
