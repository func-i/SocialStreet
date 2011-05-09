class AddScoreToFeedbacks < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :score, :integer
  end

  def self.down
    remove_column :feedbacks, :score
  end
end
