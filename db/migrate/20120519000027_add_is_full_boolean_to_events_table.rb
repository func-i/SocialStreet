class AddIsFullBooleanToEventsTable < ActiveRecord::Migration
  def change
    add_column :events, :is_full, :boolean, :default => false
  end
end
