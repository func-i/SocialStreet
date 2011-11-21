module ApplicationHelper

  def url_for_event_image(event)
    url_for_event_keyword(nil) if event.event_types.empty?
    url_for_event_keyword(ek = event.event_keywords.detect {|ek| (ek.event_type && ek.event_type.image_path?) })
  end

  def url_for_event_keyword(event_keyword)
    if event_keyword && event_keyword.event_type && event_keyword.event_type.image_path?
      event_keyword.event_type.image_path
    else
      'event_types/streetmeet' + (rand(8) + 1).to_s + '.png'
    end
  end

  def sprite_class_name_for_group(group)
    sprite_class_name_for_path(group.icon_url || ('event_types/streetmeet' + (rand(8) + 1).to_s + '.png'))
  end

  def sprite_class_name_for_event(event)
    sprite_class_name_for_path(url_for_event_image(event))
  end

  def sprite_class_name_for_path(image_path)
    start_index = image_path.index("event_types/") + "event_types/".length
    length = image_path.index(".png") - start_index
    image_path[start_index, length].gsub(/[_]/, '-')

  end

  def sprite_class_name_for_event_type(event_type)
    sprite_class_name_for_path(event_type.image_path)
  end

  def event_time_in_words(event)
    start_time = event.start_date
    end_time = event.end_date

    ss_time_ago_in_words(start_time, end_time)
  end

  def ss_time_ago_in_words(start_time, end_time = nil)
    started = (start_time < Time.now)
    ended = (end_time.nil? ? false : (end_time < Time.now))
    upcoming = !(started || ended)
    time = (ended ? end_time : start_time)
    distance_in_minutes = ((time - Time.zone.now).abs/60.0).round
    distance_in_hours = (distance_in_minutes / 60.0)
    distance_in_days = ((time.beginning_of_day - Time.zone.now.beginning_of_day).abs / (24.0 * 60.0 * 60.0)).round

    text = "#{ended ? 'Ended ' : (started ? 'Started ' : 'Starts ')}"

    case distance_in_days
    when 0
      case distance_in_hours.floor
      when 0..1
        case distance_in_minutes
        when 0..5
          text = "#{'Just ' unless upcoming}#{text}#{'in a couple of minutes ' if upcoming}"
        when 6..59
          text = "#{text}#{'in ' if upcoming}#{distance_in_minutes} minutes#{' ago' unless upcoming}"
        when 60..100
          text = "#{text}#{'in ' if upcoming}more than 1 hour #{' ago' unless upcoming}"
        when 101..120
          text = "#{text}#{'in ' if upcoming}almost 2 hours #{' ago' unless upcoming}"
        end
      when 2..23
        minutes_ratio = (distance_in_hours - distance_in_hours.floor)
        text = "#{text}#{'in ' if upcoming}more than #{distance_in_hours.floor} hours#{' ago' unless upcoming}" if minutes_ratio < 0.66
        text = "#{text}#{'in ' if upcoming}almost #{distance_in_hours.floor + 1} hours#{' ago' unless upcoming}" if minutes_ratio >= 0.66
      end
    when 1
      text = "#{text}#{upcoming ? 'Tomorrow ' : 'Yesterday '} @ #{time.strftime("%l:%M %p")}"
    when 2..6
      text = "#{text}this #{time.strftime("%A")} @ #{time.strftime("%l:%M %p")}"
    else
      text = "#{text}#{time.strftime("%A, %b %e %l:%M %p")}"
    end

    return text
  end

  def url_for_avatar(user, options={})
    return 'web-app-theme/avatar.png' unless user
    return user.avatar_url(options) || 'web-app-theme/avatar.png'
  end

  def avatar(user, options={})
    image_tag(url_for_avatar(user, :fb_size => options[:fb_size] || 'square'),
      :size=> options[:size] || "30x30",
      :class => options[:class] || "",
      :style => options[:style] || ""
    )
  end

  def address_for(location)
    if location.text?
      location.text
    else
      "#{location.street} #{location.city}, #{location.state}"
    end
  end

  def full_address_for(location)
    "#{location.street} #{location.city}, #{location.state}"
  end

  def users_current_location_string
    if cookies[:c_lng].blank? || cookies[:c_lat].blank?
      if current_user
        latitude = current_user.last_known_latitude
        longitude = current_user.last_known_longitude
      end
    else
      latitude = cookies[:c_lat].to_f
      longitude = cookies[:c_lng].to_f
    end

    latitude ||= 43.66061599944655
    longitude ||= -79.3938175316406

    return "#{latitude},#{longitude}"
  end
end
