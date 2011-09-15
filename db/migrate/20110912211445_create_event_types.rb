class CreateEventTypes < ActiveRecord::Migration
  def self.up
    create_table :event_type do |t|
      t.string :name
      t.string :image_path
      t.references :synonym
      t.references :parent
      t.timestamps
    end
  end

  def self.down
    drop_table :event_type
  end
end
