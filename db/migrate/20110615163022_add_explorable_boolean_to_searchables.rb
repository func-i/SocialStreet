class AddExplorableBooleanToSearchables < ActiveRecord::Migration
  def self.up
    add_column :searchables, :explorable, :boolean
  end

  def self.down
    remove_column :searchables, :explorable
  end
end
