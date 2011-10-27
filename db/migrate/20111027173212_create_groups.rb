class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name
      t.string :contact_name
      t.string :contact_email
      t.string :contact_phone
      t.string :contact_address
      t.string :icon_url
      t.string :header_icon_url
      t.string :join_code_description
      t.timestamps
    end
  end

  def self.down
    drop_table :groups
  end
end
