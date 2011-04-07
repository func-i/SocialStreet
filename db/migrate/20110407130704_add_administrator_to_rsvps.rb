class AddAdministratorToRsvps < ActiveRecord::Migration
  def self.up
    add_column :rsvps, :administrator, :integer, :default => 0
  end

  def self.down
    remove_column :rsvps, :administrator
  end
end
