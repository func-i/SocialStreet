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

  def url_for_event_image(event)
    if event.photo?
      event.photo.thumb.url
    elsif event.event_type && event.event_type.image_path?
      event.event_type.image_path
    else
      'web-app-theme/avatar.png'
    end
  end

  def url_for_avatar(user)
    user.avatar_url || 'web-app-theme/avatar.png'
  end

  def avatar_image(user, options={})
    image_tag(url_for_avatar(user),
      :title => user.name,
      :size=> options[:size] || "30x30")
  end

  def avatar(user, options={})
    link_to(avatar_image(user, options), profile_path(user))
  end

end
