class CreateConnections < ActiveRecord::Migration
  def self.up
    drop_table :connections
    create_table :connections do |t|
      t.references :user
      t.references :to_user
      t.integer :strength, :default => 0
      t.integer :rank
      t.boolean :facebook_friend, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :connections
    create_table :connections do |t|
      t.references :user
      t.references :to_user
      t.integer :strength
      t.integer :rank
      t.boolean :facebook_friend

      t.timestamps
    end

  end
end
