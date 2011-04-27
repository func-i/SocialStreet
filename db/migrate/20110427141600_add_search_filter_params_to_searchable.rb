class AddSearchFilterParamsToSearchable < ActiveRecord::Migration
  def self.up
    add_column :searchables,  "day_0", :boolean
    add_column :searchables,  "day_1", :boolean
    add_column :searchables,  "day_2", :boolean
    add_column :searchables,  "day_3", :boolean
    add_column :searchables,  "day_4", :boolean
    add_column :searchables,  "day_5", :boolean
    add_column :searchables,  "day_6", :boolean

    add_column :locations, :radius, :integer # in miles for now. later we will add km vs mi field

  end

  def self.down
    remove_column :searchables,  "day_0"
    remove_column :searchables,  "day_1"
    remove_column :searchables,  "day_2"
    remove_column :searchables,  "day_3"
    remove_column :searchables,  "day_4"
    remove_column :searchables,  "day_5"
    remove_column :searchables,  "day_6"

    remove_column :locations
  end
end
