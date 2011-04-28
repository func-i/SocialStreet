class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.belongs_to :event
      t.belongs_to :user
      t.belongs_to :to_user

      t.belongs_to :rsvp

      t.string :status
      
      t.timestamps
    end

    add_index :invitations, :event_id
    add_index :invitations, :user_id
    add_index :invitations, :to_user_id
    add_index :invitations, :rsvp_id
    
  end

  def self.down
    drop_table :invitations
  end
end
