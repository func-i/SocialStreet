class AddPermissionsToEventGroupsTable < ActiveRecord::Migration
  def self.up
    add_column :event_groups, :can_view, :boolean
    add_column :event_groups, :can_attend, :boolean
  end

  def self.down
    remove_column :event_groups, :can_attend
    remove_column :event_groups, :can_view
  end
end
