class FixPasswordSaltNull < ActiveRecord::Migration
  def self.up
    change_column :users, :password_salt, :string, :default => nil, :null => true
  end

  def self.down
    change_column :users, :password_salt, :string, :default => "", :null => false
  end
end
