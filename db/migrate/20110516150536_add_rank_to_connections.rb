class AddRankToConnections < ActiveRecord::Migration
  def self.up
    add_column :connections, :rank, :integer
    add_index :connections, :rank
  end

  def self.down
    remove_column :connections, :rank
  end
end
