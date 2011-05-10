class AddPhotoToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :photo, :string
  end

  def self.down
    remove_column :events, :photo
  end
end
