class ChangeColumnUserIdInEventRsvps < ActiveRecord::Migration
  def self.up
    change_column :event_rsvps, :user_id, :integer, :null => true
  end

  def self.down
    change_column :event_rsvps, :user_id, :integer, :null => false
  end
end
