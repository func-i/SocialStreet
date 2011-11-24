class CreateSmows < ActiveRecord::Migration
  def self.up
    create_table :smows do |t|
      t.integer :event_id
      t.string :top_image_url
      t.text :what_text
      t.text :where_text
      t.text :when_text
      t.string :bottom_image_url
      t.timestamps
    end
  end

  def self.down
    drop_table :smows
  end
end
