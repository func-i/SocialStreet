class AddUserEmailsAndEmailsSentToSmows < ActiveRecord::Migration
  def self.up
    add_column :smows, :emails_valid, :integer, :default => 0
    add_column :smows, :emails_sent, :integer, :default => 0
  end

  def self.down
    remove_column :smows, :emails_valid
    remove_column :smows, :emails_sent
  end
end
