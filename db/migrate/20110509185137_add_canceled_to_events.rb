class AddCanceledToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :canceled, :boolean
  end

  def self.down
    remove_column :events, :canceled
  end
end
