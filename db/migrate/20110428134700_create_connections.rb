class CreateConnections < ActiveRecord::Migration
  def self.up
    create_table :connections do |t|
      t.belongs_to :user
      t.belongs_to :to_user
      t.integer :strength

      t.timestamps
    end
    add_index :connections, :user_id
    add_index :connections, :to_user_id
  end

  def self.down
    drop_table :connections
  end
end
