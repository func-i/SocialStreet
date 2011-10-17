class AddFirstSignInDateToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :first_sign_in_date, :datetime
  end

  def self.down
    remove_column :users, :first_sign_in_date
  end
end
