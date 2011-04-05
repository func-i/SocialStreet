class CreateRsvps < ActiveRecord::Migration
  def self.up
    create_table :rsvps do |t|
      t.belongs_to :event, :null => false
      t.belongs_to :user, :null => false
      t.string :response

      t.timestamps
    end
  end

  def self.down
    drop_table :rsvps
  end
end
