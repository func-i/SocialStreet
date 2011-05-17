class AddToUserIdToActions < ActiveRecord::Migration
  def self.up
    add_column :actions, :to_user_id, :integer
    add_index :actions, :to_user_id
  end

  def self.down
    remove_column :actions, :to_user_id
  end
end
