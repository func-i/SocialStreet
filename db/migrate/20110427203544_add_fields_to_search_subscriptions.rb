class AddFieldsToSearchSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :search_subscriptions, :name, :string
  end

  def self.down
    remove_column :search_subscriptions, :name
  end
end
