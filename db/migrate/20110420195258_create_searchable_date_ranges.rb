class CreateSearchableDateRanges < ActiveRecord::Migration
  def self.up
    create_table :searchable_date_ranges do |t|
      t.belongs_to :searchable
      t.date :start_date
      t.date :end_date
      t.integer :start_time
      t.integer :end_time
      t.datetime :starts_at
      t.datetime :ends_at
      t.timestamps
    end
    add_index :searchable_date_ranges, :searchable_id
  end

  def self.down
    drop_table :searchable_date_ranges
  end
end
