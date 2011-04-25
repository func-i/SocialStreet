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

ActiveRecord::Schema.define(:version => 20110425202447) do

  create_table "activities", :force => true do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.integer  "reference_id"
    t.string   "reference_type"
    t.string   "activity_type"
    t.datetime "occurred_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "activity_id"
    t.integer  "searchable_id"
  end

  add_index "activities", ["activity_id"], :name => "index_activities_on_activity_id"
  add_index "activities", ["event_id"], :name => "index_activities_on_event_id"
  add_index "activities", ["reference_type", "reference_id"], :name => "index_activities_on_reference_type_and_reference_id"
  add_index "activities", ["searchable_id"], :name => "index_activities_on_searchable_id"
  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "auth_response"
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "searchable_id"
  end

  add_index "comments", ["commentable_type", "commentable_id"], :name => "index_comments_on_commentable_type_and_commentable_id"
  add_index "comments", ["searchable_id"], :name => "index_comments_on_searchable_id"

  create_table "event_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_path"
  end

  add_index "event_types", ["name"], :name => "index_event_types_on_name"

  create_table "events", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "cost"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_type_id"
    t.integer  "minimum_attendees"
    t.integer  "maximum_attendees"
    t.boolean  "guests_allowed"
    t.integer  "user_id"
    t.integer  "activity_id"
    t.integer  "searchable_id"
  end

  add_index "events", ["activity_id"], :name => "index_events_on_activity_id"
  add_index "events", ["event_type_id"], :name => "index_events_on_event_type_id"
  add_index "events", ["searchable_id"], :name => "index_events_on_searchable_id"
  add_index "events", ["user_id"], :name => "index_events_on_user_id"

  create_table "friendships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", :force => true do |t|
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "postal"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "text"
  end

  add_index "locations", ["latitude", "longitude"], :name => "index_locations_on_latitude_and_longitude"

  create_table "rsvps", :force => true do |t|
    t.integer  "event_id",                         :null => false
    t.integer  "user_id",                          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.boolean  "administrator", :default => false
    t.boolean  "waiting"
  end

  add_index "rsvps", ["event_id"], :name => "index_rsvps_on_event_id"
  add_index "rsvps", ["user_id"], :name => "index_rsvps_on_user_id"

  create_table "search_filters", :force => true do |t|
    t.integer  "user_id"
    t.string   "location"
    t.integer  "radius"
    t.datetime "from_date"
    t.datetime "to_date"
    t.boolean  "inclusive"
    t.integer  "from_time"
    t.integer  "to_time"
    t.boolean  "day_0"
    t.boolean  "day_1"
    t.boolean  "day_2"
    t.boolean  "day_3"
    t.boolean  "day_4"
    t.boolean  "day_5"
    t.boolean  "day_6"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "search_filters", ["user_id"], :name => "index_search_filters_on_user_id"

  create_table "searchable_date_ranges", :force => true do |t|
    t.integer  "searchable_id"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "start_time"
    t.integer  "end_time"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searchable_date_ranges", ["searchable_id"], :name => "index_searchable_date_ranges_on_searchable_id"

  create_table "searchable_event_types", :force => true do |t|
    t.integer  "searchable_id"
    t.integer  "event_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searchable_event_types", ["event_type_id"], :name => "index_searchable_event_types_on_event_type_id"
  add_index "searchable_event_types", ["searchable_id"], :name => "index_searchable_event_types_on_searchable_id"

  create_table "searchables", :force => true do |t|
    t.integer  "location_id"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searchables", ["location_id"], :name => "index_searchables_on_location_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                       :default => "", :null => false
    t.string   "encrypted_password",           :limit => 128, :default => "", :null => false
    t.string   "password_salt",                               :default => "", :null => false
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
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username"
    t.string   "facebook_profile_picture_url"
    t.string   "twitter_profile_picture_url"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
