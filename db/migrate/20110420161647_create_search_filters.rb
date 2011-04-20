class CreateSearchFilters < ActiveRecord::Migration
  def self.up
    create_table :search_filters do |t|
      t.belongs_to :user

      t.string :location
      t.integer :radius

      t.datetime :from_date
      t.datetime :to_date
      t.boolean :inclusive

      t.integer :from_time
      t.integer :to_time

      t.boolean :day_0
      t.boolean :day_1
      t.boolean :day_2
      t.boolean :day_3
      t.boolean :day_4
      t.boolean :day_5
      t.boolean :day_6
      
      t.timestamps
    end

    add_index :search_filters, :user_id
  end

  def self.down
    drop_table :search_filters
  end
end
