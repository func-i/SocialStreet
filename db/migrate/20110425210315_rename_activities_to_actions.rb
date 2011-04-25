class RenameActivitiesToActions < ActiveRecord::Migration
  def self.up
    drop_table :activities
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
    end

    add_index "actions", ["action_id"]
    add_index "actions", ["event_id"]
    add_index "actions", ["reference_type", "reference_id"]
    add_index "actions", ["searchable_id"]
    add_index "actions", ["user_id"]

    remove_column :events, :activity_id
    add_column :events, :action_id, :integer
    add_index :events, :action_id

  end

  def self.down
    drop_table :actions
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

    remove_column :events, :action_id
    add_column :events, :activity_id, :integer
    add_index :events, :activity_id

  end
end
