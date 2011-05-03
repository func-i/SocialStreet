class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :feedbacks do |t|
      t.integer :rsvp_id
      t.boolean :responded

      t.timestamps
    end
  end

  def self.down
    drop_table :feedbacks
  end
end
