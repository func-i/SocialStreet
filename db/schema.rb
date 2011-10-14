# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111014151322) do

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.text     "auth_response"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "connections", :force => true do |t|
    t.integer  "user_id"
    t.integer  "to_user_id"
    t.integer  "strength",        :default => 0
    t.integer  "rank"
    t.boolean  "facebook_friend", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_keywords", :force => true do |t|
    t.string   "name"
    t.integer  "event_type_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_rsvps", :force => true do |t|
    t.integer  "user_id"
    t.integer  "invitor_id"
    t.integer  "event_id",                              :null => false
    t.boolean  "organizer",          :default => false
    t.boolean  "posted_to_facebook", :default => false
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
  end

  create_table "event_types", :force => true do |t|
    t.string   "name"
    t.string   "image_path"
    t.integer  "synonym_id"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "location_id"
    t.integer  "user_id"
    t.boolean  "canceled",    :default => false
    t.boolean  "promoted",    :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["location_id"], :name => "index_events_on_location_id"
  add_index "events", ["user_id"], :name => "index_events_on_user_id"

  create_table "locations", :force => true do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "postal"
    t.string   "text"
    t.string   "neighborhood"
    t.string   "route"
    t.string   "geocoded_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username"
    t.string   "facebook_profile_picture_url"
    t.string   "fb_uid"
    t.string   "gender"
    t.string   "location"
    t.boolean  "accepted_tncs",                               :default => false
    t.float    "last_known_longitude"
    t.float    "last_known_latitude"
    t.datetime "last_known_location_datetime"
    t.string   "email",                                       :default => "",    :null => false
    t.string   "encrypted_password",           :limit => 128, :default => "",    :null => false
    t.string   "password_salt"
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                               :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "facebook_friends_imports"
    t.integer  "last_known_zoom_level"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["fb_uid"], :name => "index_users_on_fb_uid"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
