class ExploreController < ApplicationController
  before_filter :store_current_path, :only => [:index]

  def index
    #if !request.xhr?
    init_page
    #end
    
    @events = find_events
  end

  def search
    @events = find_events
  end

  def init_page
    @event_types = EventType.order('name').all
  end

  def find_events(args = {})
    events = Event.valid.upcoming

    #MATCH KEYWORDS
    keywords = args.key?(:keywords) ? args[:keywords] : params[:keywords]
    events = with_keywords(events, keywords)

    #MATCH MAP BOUNDS
    map_bounds = args.key?(:map_bounds) ? args[:map_bounds] : params[:map_bounds]
    events = within_bounds(events, map_bounds)

    return events.all;
  end

  def with_keywords(event, keywords)
    return event if (keywords.blank? || keywords.empty?)

    all_keywords = []
    keywords.each do |keyword|
      unless keyword.blank?
        all_keywords << keyword
        all_keywords.concat(EventType.with_parent_name(keyword).all.map(&:name))
      end
    end

    return event if all_keywords.empty?
    return event = event.matching_keywords(all_keywords, true)
  end

  def within_bounds(events, map_bounds)
    if map_bounds.blank?
      if params[:map_center]
        center = params[:map_center].split(",").collect { |point| point.to_f }
        latitude = center[0]
        longitude = center[1]
      else
        if cookies[:current_location_longitude].blank? || cookies[:current_location_latitude].blank?
          if current_user
            latitude = current_user.last_known_latitude
            longitude = current_user.last_known_longitude
          end
        else
          latitude = cookies[:current_location_latitude].to_f
          longitude = cookies[:current_location_longitude].to_f
        end
      end

      latitude ||= 43.66061599944655
      longitude ||= -79.3938175316406

      map_bounds = params[:map_bounds] = "#{latitude + 0.027},#{longitude + 0.054},#{latitude - 0.027},#{longitude - 0.054}"
    end

    bounds = map_bounds.split(",").collect { |point| point.to_f }

    params[:map_center] = "#{(bounds[0].to_f + bounds[2].to_f)/2},#{(bounds[1].to_f + bounds[3].to_f)/2}" unless params[:map_center]
    params[:map_zoom] = 12 unless params[:map_zoom]

    events = events.in_bounds(bounds[0],bounds[1],bounds[2],bounds[3])
  end

end
