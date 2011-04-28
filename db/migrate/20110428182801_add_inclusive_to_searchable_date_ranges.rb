class AddInclusiveToSearchableDateRanges < ActiveRecord::Migration
  def self.up
    add_column :searchable_date_ranges, :inclusive, :boolean
  end

  def self.down
    remove_column :searchable_date_ranges, :inclusive
  end
end
