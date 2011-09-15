class Renameeventtypes < ActiveRecord::Migration
  def self.up
    drop_table :event_type
    create_table :event_types do |t|
      t.string :name
      t.string :image_path
      t.references :synonym
      t.references :parent
      t.timestamps
    end
  end

  def self.down
    drop_table :event_types
    create_table :event_type do |t|
      t.string :name
      t.string :image_path
      t.references :synonym
      t.references :parent
      t.timestamps
    end
  end
end
