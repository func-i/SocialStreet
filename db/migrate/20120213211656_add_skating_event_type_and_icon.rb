class AddSkatingEventTypeAndIcon < ActiveRecord::Migration
  def self.up

    FileUtils.cp(File.join(Rails.root, "public", "stylesheets", "event_type_sprite.css"), File.join(Rails.root, "public", "stylesheets", "event_type_sprite.css.bak"))

    # => Col and Row starts at 0
    images = [
      {:et_name => "Skating", :image_path => "/images/event_types/skating.png", :col => 2, :row => 10}
    ]

    File.open(File.join(Rails.root, "public", "stylesheets", "event_type_sprite.css"), "a") do |file|
      images.each do |img|
        EventType.find_or_create_by_name_and_image_path(img[:et_name], img[:image_path])
        file.write(".event-type-#{img[:et_name].downcase}-small-sprite { display: inline-block; background: url('../images/event_types/small_sprite.png') no-repeat;  background-position: -#{(img[:col].zero? ? 0 : img[:col] * 55)}px -#{img[:row].zero? ? 0 : img[:row] * 55}px; width: 55px; height: 55px; }")
        file.write("\r\n")
        file.write(".event-type-#{img[:et_name].downcase}-medium-sprite { display: inline-block; background: url('../images/event_types/medium_sprite.png') no-repeat; background-position: -#{(img[:col].zero? ? 0 : img[:col] * 70)}px -#{img[:row].zero? ? 0 : img[:row] * 70}px; width: 70px; height: 70px; }")
        file.write("\r\n")
      end
    end

  end

  def self.down

    images = [
      {:et_name => "Skating", :image_path => "/images/event_types/skating.png"}
    ]

    images.each do |img|
      EventType.find_by_name(img[:et_name]).destroy rescue nil
    end

    FileUtils.cp(File.join(Rails.root, "public", "stylesheets", "event_type_sprite.css.bak"), File.join(Rails.root, "public", "stylesheets", "event_type_sprite.css"))

  end
end
