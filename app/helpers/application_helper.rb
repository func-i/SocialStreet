module ApplicationHelper

  def event_type_name(event)
    !event.searchable_event_types.empty? ? event.searchable_event_types.collect(&:name).join(", ") : "Unknown Type"
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

  def display_date_time(time)
    time.to_s(:date_with_day) + " at " + time.to_s(:time12h) + " #{Time.zone.now.zone}"
  end
  
  def url_for_event_image(event)
    if event.photo?
      event.photo.thumb.url
    elsif !event.event_types.blank? && et = event.event_types.detect {|et| et.image_path? }
      et.image_path
    else
      'event_types/streetmeet' + (rand(8) + 1).to_s + '.png'
      #'web-app-theme/avatar.png'
    end
  end

  def url_for_avatar(user, options={})
    user.avatar_url(options) || 'web-app-theme/avatar.png'
  end

  def avatar_image(user, options={})
    image_tag(url_for_avatar(user, :fb_size => options[:fb_size] || 'square'),
      :title => user.name,
      :size=> options[:size] || "30x30"
      )
  end

  def avatar(user, options={})
    if options[:exclude_link] && options[:exclude_link] == true
      avatar_image(user, options)
    else
      link_to(avatar_image(user, options), profile_path(user))
    end
  end

  def link_to_popup_modal(title, div_id, options = {}, html_options = {})
    klass = options.delete(:class)
    options.merge!(
      :class => "popup-modal #{klass}".strip,
      "popup-div-id" => div_id)
    
    link_to title, '#', options, html_options
  end

  # Will display a modal and the contents will load via an AJAX request
  # first param is the text
  #
  def link_to_popup_modal_ajax(link_text, modal_title, modal_div_id, request_url, request_callback, request_params = {}, options = {}, html_options = {})
    klass = options.delete(:class)
    options.merge!(
      :class => "popup-modal-ajax #{klass}".strip,
      "popup-div-id" => modal_div_id,
      "request-url" => request_url,
      "modal-title" => modal_title,
      "request-callback" => request_callback)

    link_to link_text, '#', options, html_options

  end

  def ss_time_ago_in_words(start_time, end_time = nil)
    compare_time = start_time.is_a?(Date) ? Date.today : Time.now
    compare_date = compare_time.is_a?(Date) ? compare_time : compare_time.to_date
    d_diff = (compare_date - Date.today).to_i

    if d_diff > -7 && d_diff < 14
      if d_diff < 0
        # => The date is less than 2 weeks old.
      else

      end
    end

    if(end_time)
      if( start_time < compare_time )
        if( end_time > compare_time )
          return 'started ' + time_ago_in_words(start_time) + ' ago - ' + time_ago_in_words(end_time) + ' remaining'
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

end
