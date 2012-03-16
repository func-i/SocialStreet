class AddFreeOptionalToSmows < ActiveRecord::Migration
  def change
    add_column :smows, :free, :boolean, :default => true
  end
end
