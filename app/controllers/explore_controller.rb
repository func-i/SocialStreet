class ExploreController < ApplicationController
  before_filter :store_current_path, :only => [:index]

  def index
    @page_title = "Explore"

    init_page

    @promoted_events = Event.where(:promoted => true).upcoming.limit(1).all

    @events = find_events

    @events = @events.order("events.start_date ASC");
    @events = @events.all

    @events = @events.reject{|item| @promoted_events.include?(item)} unless @promoted_events.blank?

    if request.xhr?
      render "shared/ajax_load.js", :locals => {:file_name_var => 'explore/index.html.erb'}
    end
  end

  def search
    @promoted_events = Event.where(:promoted => true).upcoming.limit(1).all

    @events = find_events
    @events = @events.reject{|item| @promoted_events.include?(item)} unless @promoted_events.blank?
  end

  def init_page
    @event_types = EventType.order('name').includes(:synonym).all
  end

  def find_events(args = {})
    events = Event.valid.upcoming

    #MATCH KEYWORDS
    keywords = args.key?(:keywords) ? args[:keywords] : params[:keywords]
    events = with_keywords(events, keywords)

    #MATCH MAP BOUNDS
    map_bounds = args.key?(:map_bounds) ? args[:map_bounds] : params[:map_bounds]
    events = within_bounds(events, map_bounds)

    return events;
  end

  def with_keywords(event, keywords)
    return event.includes({:event_keywords => {:event_type => :synonym}}) if (keywords.blank? || keywords.empty?)
    
    enhanced_keywords = []
    keywords.each do |keyword|
      unless keyword.blank?
        enhanced_keywords << keyword
        enhanced_keywords.concat(EventType.with_name(keyword).joins(:synonym).all.collect(&:synonym).map(&:name))
      end
    end

    all_keywords = []
    enhanced_keywords.each do |keyword|
      unless keyword.blank?
        all_keywords << keyword
        all_keywords.concat(EventType.with_parent_name(keyword).all.map(&:name))
      end
    end

    return event if all_keywords.empty?
    return event = event.matching_keywords(all_keywords, true)
  end

  def within_bounds(events, map_bounds)
    if params[:map_zoom].blank?
      if cookies[:c_zoom].blank?
        if current_user
          zoom_level = current_user.last_known_zoom_level
        end
      else
        zoom_level = cookies[:c_zoom]
      end

      params[:map_zoom] = zoom_level ||= 12
    end

    if params[:map_center]
      center = params[:map_center].split(",").collect { |point| point.to_f }
      latitude = center[0]
      longitude = center[1]
    else
      if cookies[:c_lng].blank? || cookies[:c_lat].blank?
        if current_user
          latitude = current_user.last_known_latitude
          longitude = current_user.last_known_longitude
        end
      else
        latitude = cookies[:c_lat].to_f
        longitude = cookies[:c_lng].to_f
      end
    end

    latitude ||= 43.66061599944655
    longitude ||= -79.3938175316406

    params[:map_center] = "#{latitude},#{longitude}"

    if map_bounds
      ne_lat, ne_lng, sw_lat, sw_lng = map_bounds.split(",").collect { |point| point.to_f }
    else
      if cookies[:c_sw_lng].blank? || cookies[:c_sw_lat].blank? || cookies[:c_ne_lng].blank? || cookies[:c_ne_lat].blank?
        if current_user
          sw_lng = current_user.last_known_bounds_sw_lng
          sw_lat = current_user.last_known_bounds_sw_lat
          ne_lng = current_user.last_known_bounds_ne_lng
          ne_lat = current_user.last_known_bounds_ne_lat
        end
      else
        sw_lng = cookies[:c_sw_lng]
        sw_lat = cookies[:c_sw_lat]
        ne_lng = cookies[:c_ne_lng]
        ne_lat = cookies[:c_ne_lat]
      end
    end

    sw_lng ||= longitude - 0.054
    sw_lat ||= latitude - 0.027
    ne_lng ||= longitude + 0.054
    ne_lat ||= latitude + 0.027

    params[:map_bounds] = "#{ne_lat},#{ne_lng},#{sw_lat},#{sw_lng}"

    #SEARCH FOR EVENTS IN BOUNDS
    events = events.in_bounds(ne_lat,ne_lng,sw_lat,sw_lng)
  end
end
