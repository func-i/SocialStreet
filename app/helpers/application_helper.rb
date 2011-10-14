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
    distance_in_minutes = ((time - Time.now).abs/60).round
    distance_in_hours = (distance_in_minutes / 60).floor
    distance_in_days = (distance_in_hours / 24).floor

    time_of_day = (time.hour() > 21 ? 'Night' : (time.hour() > 17 ? 'Evening' : (time.hour() > 12 ? 'Afternoon' : 'Morning')))
    
    text = "#{ended ? 'Ended ' : (started ? 'Started ' : 'Starts ')}"

    case distance_in_hours
    when 0
      text = "#{text}#{'in ' if upcoming}#{distance_in_minutes} minutes#{' ago' unless upcoming}"
    when 1..23
      text = "#{text}#{'in ' if upcoming}#{distance_in_hours} hours#{' ago' unless upcoming}"
    else
      case distance_in_days
      when 1
        text = "#{text}#{upcoming ? 'Tomorrow ' : 'Yesterday '} @ #{time.strftime("%l:%M %p")}"
      when 2..6
        text = "#{text}this #{time.strftime("%A")} @ #{time.strftime("%l:%M %p")}"
      #when 7..13
        #text = "#{text}#{upcoming ? 'next  ' : 'last '}#{time.strftime("%A")} #{time_of_day}"
      else
        text = "#{text}#{time.strftime("%A, %b %e %l:%M %p")}"
      end
    end
  end

  def url_for_avatar(user, options={})
    return 'web-app-theme/avatar.png' unless user
    return user.avatar_url(options) || 'web-app-theme/avatar.png'
  end

  def avatar(user, options={})
    image_tag(url_for_avatar(user, :fb_size => options[:fb_size] || 'square'),
      :title => user.try(:name),
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

  def users_current_location_string
    if cookies[:current_location_longitude].blank? || cookies[:current_location_latitude].blank?
      if current_user
        latitude = current_user.last_known_latitude
        longitude = current_user.last_known_longitude
      end
    else
      latitude = cookies[:current_location_latitude].to_f
      longitude = cookies[:current_location_longitude].to_f
    end

    latitude ||= 43.66061599944655
    longitude ||= -79.3938175316406

    return "#{latitude},#{longitude}"
  end
end
