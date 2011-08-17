class AddAcceptedTncToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :accepted_tncs, :boolean, :default => false
  end

  def self.down
    remove_column :users, :accepted_tncs
  end
end
