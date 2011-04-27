class AddDowToSearchableDateRanges < ActiveRecord::Migration
  def self.up
    add_column :searchable_date_ranges, :dow, :integer
    remove_column :searchables,  "day_0"
    remove_column :searchables,  "day_1"
    remove_column :searchables,  "day_2"
    remove_column :searchables,  "day_3"
    remove_column :searchables,  "day_4"
    remove_column :searchables,  "day_5"
    remove_column :searchables,  "day_6"

  end

  def self.down
    remove_column :searchable_date_ranges, :dow
    add_column :searchables,  "day_0", :boolean
    add_column :searchables,  "day_1", :boolean
    add_column :searchables,  "day_2", :boolean
    add_column :searchables,  "day_3", :boolean
    add_column :searchables,  "day_4", :boolean
    add_column :searchables,  "day_5", :boolean
    add_column :searchables,  "day_6", :boolean

  end
end
