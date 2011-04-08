module ApplicationHelper

  def address_for(location)
    if location.text?
      location.text
    else
      "#{location.street} #{location.city}, #{location.state}"
    end
  end

  def display_date_time(time)
    time.to_s(:date_with_day) + " at " + time.to_s(:time12h) + " #{Time.zone.now.zone}"
  end

  def event_image(event)
    if event.custom_image?
      "custom image URL here"
    elsif event.event_type && event.event_type.image_path?
      event.event_type.image_path
    else
      'web-app-theme/avatar.png'
    end
  end
end
