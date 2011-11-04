class AddAppliedToUserGroupsTable < ActiveRecord::Migration
  def self.up
    add_column :user_groups, :applied, :boolean
  end

  def self.down
    remove_column :user_groups, :applied
  end
end
