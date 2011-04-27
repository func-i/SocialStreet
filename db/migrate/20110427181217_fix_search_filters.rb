class FixSearchFilters < ActiveRecord::Migration
  def self.up
    drop_table :search_filters
    create_table :search_subscriptions do |t|
      t.belongs_to :user
      t.belongs_to :searchable
      t.string :frequency
      t.timestamps
    end
    add_index :search_subscriptions, :user_id
    add_index :search_subscriptions, :searchable_id
  end

  def self.down
    drop_table :search_subscriptions

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
  end
end
