class M::ExploreController < MobileController
  before_filter :ss_authenticate_user!

  def index
    init_page
    
    get_events
  end

  protected

  def init_page
    @event_types = EventType.order('name').includes(:synonym).all
    @all_groups = Group.all
  end


  def get_events()
    @promoted_events = Event.where(:promoted => true).upcoming.limit(1).all

    @events = find_events

    @events = @events.order("events.start_date ASC");
    @events = @events.all

    @events = @events.reject{|item| @promoted_events.include?(item)} unless @promoted_events.blank?
  end

  def find_events(args = {})
    events = Event.valid.upcoming

    params[:keywords] ||= []
    params[:keywords] = [params[:keywords]] unless params[:keywords].is_a?(Array)

    # => MATCH GROUPS    
    params[:keywords] << @group.name if @group
    
    # => MATCH KEYWORDS
    keywords = args.key?(:keywords) ? args[:keywords] : params[:keywords]
    events = with_keywords(events, keywords)

    # Permissions
    events = with_permission(events)

    # => MATCH MAP BOUNDS
    map_bounds = args.key?(:map_bounds) ? args[:map_bounds] : params[:map_bounds]
    map_zoom = args.key?(:map_zoom) ? args[:map_zoom] : params[:map_zoom]
    events = within_bounds(events, map_bounds, map_zoom)

    return events;
  end

  def with_permission(events)
    query = []
    query << "(
      NOT events.private
    )"

    if current_user
      events = events.includes(:event_groups)
      current_user.user_groups.each do |user_group|
        query << "(event_groups.group_id = #{user_group.group_id} AND event_groups.can_view)"
      end
    end

    return events.where(query.join(" OR "))
  end

  def with_keywords(events, keywords)
    return events.includes({:event_keywords => {:event_type => :synonym}}) if (keywords.blank? || keywords.empty?)

    # => Collect event type synonyms
    enhanced_keywords = []
    keywords.each do |keyword|
      unless keyword.blank?
        enhanced_keywords << keyword
        enhanced_keywords.concat(EventType.with_name(keyword).joins(:synonym).all.collect(&:synonym).map(&:name))
      end
    end

    # => Create a master array for all keywords
    all_keywords = []

    # => Loop through each of the synonym keywords and find synonyms for those
    enhanced_keywords.each do |keyword|
      unless keyword.blank?

        all_keywords << keyword

        # => Add all synonyms of this keyword
        all_keywords.concat(EventType.with_parent_name(keyword).all.map(&:name))
      end
    end

    return events if all_keywords.empty?
    return events = events.matching_keywords(all_keywords, true)
  end

  def within_bounds(events, map_bounds, zoom_level)
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


    loop_counter = 0
    event_count = -1
    stored_event_query = nil
    stored_bounds = nil
    while loop_counter < 5
      new_event_query = within_bounds_instance(events, ne_lat, ne_lng, sw_lat, sw_lng)

      if new_event_query.count > event_count
        event_count = new_event_query.count
        stored_event_query = new_event_query
        stored_bounds = "#{ne_lat},#{ne_lng},#{sw_lat},#{sw_lng}"
      end

      if !map_bounds.nil? || event_count >= 5
        loop_counter = 5
      else
        loop_counter = loop_counter + 1

        sw_lng = sw_lng - 0.054
        sw_lat = sw_lat - 0.027
        ne_lng = ne_lng + 0.054
        ne_lat = ne_lat + 0.027
      end
    end

    params[:map_bounds] = stored_bounds

    return stored_event_query
  end

  def within_bounds_instance(events, ne_lat, ne_lng, sw_lat, sw_lng)
    #SEARCH FOR EVENTS IN BOUNDS
    events.in_bounds(ne_lat,ne_lng,sw_lat,sw_lng)
  end
end
