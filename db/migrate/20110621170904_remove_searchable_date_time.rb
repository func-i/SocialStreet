class RemoveSearchableDateTime < ActiveRecord::Migration
  def self.up
    # for some reason this table shows up in development schema.rb but not in staging/prod
    drop_table :searchable_date_time if Rails.env.development?
  rescue
    puts "drop_table :searchable_date_time failed (safe to ignore - KV)"
  end

  def self.down
    # nada
  end
end
