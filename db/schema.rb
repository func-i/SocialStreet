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

ActiveRecord::Schema.define(:version => 20110723160131) do

  create_table "actions", :force => true do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.integer  "reference_id"
    t.string   "reference_type"
    t.string   "action_type"
    t.datetime "occurred_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "action_id"
    t.integer  "searchable_id"
    t.integer  "to_user_id"
  end

  add_index "actions", ["action_id"], :name => "index_actions_on_action_id"
  add_index "actions", ["event_id"], :name => "index_actions_on_event_id"
  add_index "actions", ["reference_type", "reference_id"], :name => "index_actions_on_reference_type_and_reference_id"
  add_index "actions", ["searchable_id"], :name => "index_actions_on_searchable_id"
  add_index "actions", ["to_user_id"], :name => "index_actions_on_to_user_id"
  add_index "actions", ["user_id"], :name => "index_actions_on_user_id"

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

  create_table "connections", :force => true do |t|
    t.integer  "user_id"
    t.integer  "to_user_id"
    t.integer  "strength"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "facebook_friend"
    t.integer  "rank"
  end

  add_index "connections", ["rank"], :name => "index_connections_on_rank"
  add_index "connections", ["to_user_id"], :name => "index_connections_on_to_user_id"
  add_index "connections", ["user_id"], :name => "index_connections_on_user_id"

  create_table "event_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_path"
    t.integer  "synonym_id"
  end

  add_index "event_types", ["name"], :name => "index_event_types_on_name"
  add_index "event_types", ["synonym_id"], :name => "index_event_types_on_synonym_id"

  create_table "events", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "cost"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "minimum_attendees"
    t.integer  "maximum_attendees"
    t.boolean  "guests_allowed"
    t.integer  "user_id"
    t.integer  "searchable_id"
    t.integer  "action_id"
    t.boolean  "canceled"
    t.string   "photo"
  end

  add_index "events", ["action_id"], :name => "index_events_on_action_id"
  add_index "events", ["searchable_id"], :name => "index_events_on_searchable_id"
  add_index "events", ["user_id"], :name => "index_events_on_user_id"

  create_table "feedbacks", :force => true do |t|
    t.integer  "rsvp_id"
    t.boolean  "responded"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "score"
  end

  create_table "invitations", :force => true do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.integer  "to_user_id"
    t.integer  "rsvp_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
  end

  add_index "invitations", ["event_id"], :name => "index_invitations_on_event_id"
  add_index "invitations", ["rsvp_id"], :name => "index_invitations_on_rsvp_id"
  add_index "invitations", ["to_user_id"], :name => "index_invitations_on_to_user_id"
  add_index "invitations", ["user_id"], :name => "index_invitations_on_user_id"

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
    t.integer  "radius"
    t.integer  "user_id"
    t.boolean  "system"
    t.float    "sw_lat"
    t.float    "sw_lng"
    t.float    "ne_lat"
    t.float    "ne_lng"
  end

  add_index "locations", ["latitude", "longitude"], :name => "index_locations_on_latitude_and_longitude"
  add_index "locations", ["user_id"], :name => "index_locations_on_user_id"

  create_table "rsvps", :force => true do |t|
    t.integer  "event_id",                              :null => false
    t.integer  "user_id",                               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.boolean  "administrator",      :default => false
    t.boolean  "waiting"
    t.boolean  "posted_to_facebook", :default => false
  end

  add_index "rsvps", ["event_id"], :name => "index_rsvps_on_event_id"
  add_index "rsvps", ["user_id"], :name => "index_rsvps_on_user_id"

  create_table "search_subscriptions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "searchable_id"
    t.string   "frequency"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "search_subscriptions", ["searchable_id"], :name => "index_search_subscriptions_on_searchable_id"
  add_index "search_subscriptions", ["user_id"], :name => "index_search_subscriptions_on_user_id"

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
    t.integer  "dow"
    t.boolean  "inclusive"
  end

  add_index "searchable_date_ranges", ["searchable_id"], :name => "index_searchable_date_ranges_on_searchable_id"

  create_table "searchable_event_types", :force => true do |t|
    t.integer  "searchable_id"
    t.integer  "event_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "searchable_event_types", ["event_type_id"], :name => "index_searchable_event_types_on_event_type_id"
  add_index "searchable_event_types", ["searchable_id"], :name => "index_searchable_event_types_on_searchable_id"

  create_table "searchables", :force => true do |t|
    t.integer  "location_id"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "explorable"
    t.boolean  "ignored",     :default => false
  end

  add_index "searchables", ["location_id"], :name => "index_searchables_on_location_id"

  create_table "tmp_feed_items", :force => true do |t|
    t.integer  "action_id"
    t.integer  "event_id"
    t.integer  "user_id"
    t.string   "feed_type"
    t.string   "inserted_because"
    t.datetime "last_touched"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                         :default => "",    :null => false
    t.string   "encrypted_password",             :limit => 128, :default => "",    :null => false
    t.string   "password_salt",                                 :default => "",    :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                 :default => 0
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
    t.string   "comment_notification_frequency"
    t.string   "fb_uid"
    t.string   "photo"
    t.boolean  "fb_friends_imported",                           :default => false
    t.string   "gender"
    t.string   "location"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["fb_uid"], :name => "index_users_on_fb_uid"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
