class CreateUserGroups < ActiveRecord::Migration
  def self.up
    create_table :user_groups do |t|
      t.integer :user_id
      t.integer :group_id
      t.string :join_code
      t.string :external_name
      t.string :external_email
      t.boolean :administrator
      t.timestamps
    end

    add_index :user_groups, :user_id
    add_index :user_groups, :group_id
    add_index :user_groups, :join_code

  end

  def self.down
    drop_table :user_groups
  end
end
