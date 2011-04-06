class AddAuthResponseToAuthentications < ActiveRecord::Migration
  def self.up
    add_column :authentications, :auth_response, :text
  end

  def self.down
    remove_column :authentications, :auth_response
  end
end
