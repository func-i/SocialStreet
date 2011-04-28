class AddCommentFrequencyToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :comment_notification_frequency, :string
  end

  def self.down
    remove_column :users, :comment_notification_frequency
  end
end
