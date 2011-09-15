class CreateConnectionsTable < ActiveRecord::Migration
  def self.up
    create_table :connections do |t|
      t.references :user
      t.references :to_user
      t.integer :strength
      t.integer :rank
      t.boolean :facebook_friend

      t.timestamps
    end
  end

  def self.down
    drop_table :connections

  end
end
