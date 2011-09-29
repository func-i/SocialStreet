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

  def ss_time_ago_in_words(start_time, end_time = nil)
    compare_time = start_time.is_a?(Date) ? Date.today : Time.now

    if(end_time)
      if( start_time < compare_time )
        if( end_time > compare_time )
          #return 'started ' + time_ago_in_words(start_time) + ' ago - ' + time_ago_in_words(end_time) + ' remaining'
          return 'started ' + time_ago_in_words(start_time) + ' ago'
        else
          return 'ended ' + time_ago_in_words(end_time) + ' ago'
        end
      end
    end

    if( start_time > compare_time)
      return 'in ' + time_ago_in_words(start_time)
    else
      return time_ago_in_words(start_time) + ' ago'
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
      :class => options[:class] || ""
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
