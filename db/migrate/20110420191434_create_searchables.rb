class CreateSearchables < ActiveRecord::Migration
  def self.up
    create_table :searchables do |t|
      t.belongs_to :location
      t.float :latitude
      t.float :longitude
      t.timestamps
    end

    add_index :searchables, :location_id

    add_column :events, :searchable_id, :integer
    add_column :comments, :searchable_id, :integer
    add_column :activities, :searchable_id, :integer

    add_index :events, :searchable_id
    add_index :comments, :searchable_id
    add_index :activities, :searchable_id

    remove_column :events, :location_id
    remove_column :events, :latitude
    remove_column :events, :longitude

  end

  def self.down
    drop_table :searchables

    remove_column :events, :searchable_id
    remove_column :comments, :searchable_id
    remove_column :activities, :searchable_id


    add_column :events, :location_id, :integer
    add_column :events, :latitude, :float
    add_column :events, :longitude, :float
  end
end
