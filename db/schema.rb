# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20120316152706) do

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.text     "auth_response"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"

  create_table "chat_rooms", :force => true do |t|
    t.string   "name"
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chat_rooms_users", :id => false, :force => true do |t|
    t.integer "chat_room_id"
    t.integer "user_id"
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["event_id"], :name => "index_comments_on_event_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "connections", :force => true do |t|
    t.integer  "user_id"
    t.integer  "to_user_id"
    t.integer  "strength",        :default => 0
    t.integer  "rank"
    t.boolean  "facebook_friend", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "connections", ["to_user_id"], :name => "index_connections_on_to_user_id"
  add_index "connections", ["user_id"], :name => "index_connections_on_user_id"

  create_table "event_groups", :force => true do |t|
    t.integer  "event_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "can_view"
    t.boolean  "can_attend"
  end

  create_table "event_keywords", :force => true do |t|
    t.string   "name"
    t.integer  "event_type_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_keywords", ["event_id"], :name => "index_event_keywords_on_event_id"
  add_index "event_keywords", ["event_type_id"], :name => "index_event_keywords_on_event_type_id"

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
    t.string   "prompt_answer"
  end

  add_index "event_rsvps", ["event_id"], :name => "index_event_rsvps_on_event_id"
  add_index "event_rsvps", ["invitor_id"], :name => "index_event_rsvps_on_invitor_id"
  add_index "event_rsvps", ["user_id"], :name => "index_event_rsvps_on_user_id"

  create_table "event_types", :force => true do |t|
    t.string   "name"
    t.string   "image_path"
    t.integer  "synonym_id"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_types", ["parent_id"], :name => "index_event_types_on_parent_id"
  add_index "event_types", ["synonym_id"], :name => "index_event_types_on_synonym_id"

  create_table "events", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "location_id"
    t.integer  "user_id"
    t.boolean  "canceled",        :default => false
    t.boolean  "promoted",        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "private",         :default => false
    t.string   "prompt_question"
  end

  add_index "events", ["location_id"], :name => "index_events_on_location_id"
  add_index "events", ["user_id"], :name => "index_events_on_user_id"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "contact_name"
    t.string   "contact_email"
    t.string   "contact_phone"
    t.string   "contact_address"
    t.string   "icon_url"
    t.string   "header_icon_url"
    t.string   "join_code_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
  end

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

  create_table "messages", :force => true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chat_room_id"
  end

  add_index "messages", ["chat_room_id"], :name => "index_messages_on_chat_room_id"

  create_table "smows", :force => true do |t|
    t.integer  "event_id"
    t.string   "top_image_url"
    t.text     "what_text"
    t.text     "where_text"
    t.text     "when_text"
    t.string   "bottom_image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "emails_valid",     :default => 0
    t.integer  "emails_sent",      :default => 0
    t.string   "title"
    t.string   "icon_path"
    t.string   "bottom_text"
    t.boolean  "free",             :default => true
  end

  create_table "user_groups", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.string   "join_code"
    t.string   "external_name"
    t.string   "external_email"
    t.boolean  "administrator"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "applied"
  end

  add_index "user_groups", ["group_id"], :name => "index_user_groups_on_group_id"
  add_index "user_groups", ["join_code"], :name => "index_user_groups_on_join_code"
  add_index "user_groups", ["user_id"], :name => "index_user_groups_on_user_id"

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
    t.integer  "last_known_bounds_sw_lat"
    t.integer  "last_known_bounds_sw_lng"
    t.integer  "last_known_bounds_ne_lat"
    t.integer  "last_known_bounds_ne_lng"
    t.datetime "first_sign_in_date"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["fb_uid"], :name => "index_users_on_fb_uid"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
