module ApplicationHelper

  def url_for_event_image(event)
    if !event.event_types.empty? && et = event.event_types.detect {|et| et.image_path? }
      et.image_path
    else
      'event_types/streetmeet' + (rand(8) + 1).to_s + '.png'
    end
  end

  def ss_time_ago_in_words(start_time, end_time = nil)
    compare_time = start_time.is_a?(Date) ? Date.today : Time.now

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

  def url_for_avatar(user, options={})
    (user && user.avatar_url(options)) || 'web-app-theme/avatar.png'
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



end
