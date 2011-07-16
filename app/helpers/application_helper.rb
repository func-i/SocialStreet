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

  def display_date_time(time)
    time.to_s(:date_with_day) + " at " + time.to_s(:time12h) + " #{Time.zone.now.zone}"
  end
  
  def url_for_event_image(event)
    if event.photo?
      event.photo.thumb.url
    elsif !event.event_types.blank? && et = event.event_types.detect {|et| et.image_path? }
      et.image_path
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

end
