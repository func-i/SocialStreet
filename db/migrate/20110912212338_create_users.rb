class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :username
      t.string :facebook_profile_picture_url
      t.string :fb_uid
      t.string :gender
      t.string :location

      t.boolean :accepted_tncs, :default => false

      t.float :last_known_longitude
      t.float :last_known_latitude
      t.datetime :last_known_location_datetime
      
      t.string :email, :default => "", :null => false
      t.string :encrypted_password, :limit => 128, :default => "", :null => false
      t.string   :password_salt
      t.string   :reset_password_token
      t.string   :remember_token
      t.datetime :remember_created_at
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.timestamps
    end

    add_index "users", ["email"], :name => "index_users_on_email"
    add_index "users", ["fb_uid"], :name => "index_users_on_fb_uid"
    add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  end

  def self.down
    drop_table :users
  end
end
