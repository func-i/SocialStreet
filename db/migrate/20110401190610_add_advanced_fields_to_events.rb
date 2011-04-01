class AddAdvancedFieldsToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :minimum_attendees, :integer
    add_column :events, :maximum_attendees, :integer
    add_column :events, :guests_allowed, :boolean

    remove_column :events, :free
    
  end

  def self.down
    add_column :events, :free, :boolean
    remove_column :events, :minimum_attendees
    remove_column :events, :maximum_attendees
    remove_column :events, :guests_allowed
  end
end
