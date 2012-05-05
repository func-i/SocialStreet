class AddRsvpTextToEventsTable < ActiveRecord::Migration
  def change
    add_column :events, :rsvp_text, :text
  end
end
