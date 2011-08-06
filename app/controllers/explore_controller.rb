class ExploreController < ApplicationController
  include Mixins::GeneralHelpers::ClassMethods
  
  before_filter :load_event_types
  before_filter :store_current_path

  MORE_RESULTS_LIMIT = 10
  
  def index    
    @comment = Comment.new

    # Use the query params to find events
    find_searchables
    
    #message_searchables = find_messages
    #event_searchables = find_events
    #merge_events_and_messages(event_searchables, message_searchables)
    

    if request.xhr? && params[:page] # pagination request
      render :partial => 'new_page'
    else
      find_overlapping_subscriptions # not needed for pagination request, hence in here - KV
    end
  end

  protected

  def load_event_types
    @event_types ||= EventType.order('name').all
  end

  def find_overlapping_subscriptions
    @overlapping_subscriptions = Searchable.with_only_subscriptions

    @overlapping_subscriptions = apply_filter(@overlapping_subscriptions)
    @overlapping_subscriptions = @overlapping_subscriptions.where("search_subscriptions.user_id != #{current_user.id}") if current_user
    @overlapping_subscriptions_count = @overlapping_subscriptions.count;

    # this executes a full search, which is bad, we want to paginate (eventually)
    @overlapping_subscriptions = @overlapping_subscriptions.limit(8).uniq_by {|s| s.search_subscription.user_id }
    
  end

  def find_searchables
    @searchables = Searchable.explorable

    @searchables = apply_filter(@searchables)
    
    @per_page = 10
    
    # => The threshold for showing the comment suggest
    @comment_suggest_limit = 5

    @offset = ((params[:page] || 1).to_i * @per_page) - @per_page
    @searchable_total_count = @searchables.count
    @searchables = @searchables.limit(@per_page).offset(@offset)
    
    # => Expand Search here to find similar results
    if @searchable_total_count < @comment_suggest_limit
      3.times do |i|
        case i
        when 0
          # => Relax date range
          @similar_results = Searchable.explorable
          @similar_results = apply_filter(@similar_results, :from_date => nil)
        when 1
          # => Relax map radius to 100km/62miles from center
          @similar_results = Searchable.explorable
          
          expanded_bounds = Geocoder::Calculations.bounding_box(params[:map_center].split(",").map{|i| i.to_f}, 100, :units=>:km)          
          @similar_results = apply_filter(@similar_results, :from_date => nil, :map_bounds => [expanded_bounds[2], expanded_bounds[3], expanded_bounds[0], expanded_bounds[1]].join(","))
        when 2
          # => Relax keywords
          @similar_results = Searchable.explorable
          expanded_bounds = Geocoder::Calculations.bounding_box(params[:map_center].split(",").map{|i| i.to_f}, 100, :units=>:km)
          @similar_results = apply_filter(@similar_results,
            :from_date => nil,
            :map_bounds => [expanded_bounds[2], expanded_bounds[3], expanded_bounds[0], expanded_bounds[1]].join(","),
            :keywords => nil)
        end
        
        @similar_results = @similar_results.where("searchables.id NOT IN(?)", @searchables.collect(&:id)) unless @searchables.empty?

        break if @similar_results.count > 50
      end      

      @total_count = @similar_results.count
      @similar_results = @similar_results.limit(@per_page).offset(@offset)          

    end
    
    @num_pages = (@searchable_total_count.to_f / @per_page.to_f).ceil
  end

  ##TODO
  #-> Write searchables only_messages and only_events functions
  #-> Write score functions
  #-> Figure out paging

  def find_messages
    messages = Searchable.explorable.where(:ignored => false)
    messages = messages.only_messages

    messages = apply_message_filter(messages)

    @messages_per_page = 5
    @messages_offset = ((params[:page] || 1).to_i * @messages_per_page) - @messages_per_page
    @messages_total_count = messages.count

    messages = messages.limit(@messages_per_page).offset(@messages_offset)

  end

  def find_events
    events = Searchable.explorable.where(:ignored => false)
    events = events.only_events

    events = apply_event_filter(events)

    @events_per_page = 5
    @events_offset = ((params[:page] || 1).to_i * @events_per_page) - @events_per_page
    @events_total_count = events.count

    events = events.limit(@events_per_page).offset(@events_offset)
  end

  def merge_events_and_messages(events, messages)
    events_with_scores = score_events(events)
    messages_with_scores = score_messages(messages);

    merged_array = event_with_scores + messages_with_scores

    sorted_array = merged_array.sort_by(&:score);
  end

  def score_events(events)

  end

  def apply_message_filter(messages, args = {})
    #MATCH KEYWORDS
    keywords = args.key?(:keywords) ? args[:keywords] : params[:keywords]
    apply_keywords(messages, keywords)

    #MATCH MAP BOUNDS
    map_bounds = args.key?(:map_bounds) ? args[:map_bounds] : params[:map_bounds]
    apply_map_bounds(messages, map_bounds)
  end

  def apply_event_filter(events, args = {})
    #MATCH KEYWORDS
    keywords = args.key?(:keywords) ? args[:keywords] : params[:keywords]
    apply_keywords(events, keywords)

    #MATCH MAP BOUNDS
    map_bounds = args.key?(:map_bounds) ? args[:map_bounds] : params[:map_bounds]
    apply_map_bounds(events, map_bounds)

    #MATCH DOW
    dow_obj = args.key?(:dow) ? args[:dow] : params[:date_search]
    apply_dow(events, dow_obj)

    #MATCH FROM DATE
    from_date = args.key?(:from_date) ? args[:from_date] : params[:from_date]
    apply_from_date(events, from_date)
  end

  def apply_keywords(searchable, keywords)
    return searchable if keywords.blank?

    searchable = searchable.with_keywords(keywords)
  end

  def apply_map_bounds(searchable, map_bounds)
    # order: ne_lat, ne_lng, sw_lat, sw_lng
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

        #TODO - unlogged in user coming to our site for first time...setting to toronto for now...
        latitude ||= 43.66061599944655
        longitude ||= -79.3938175316406

        params[:map_center] = "#{latitude},#{longitude}"
      end

      map_bounds = params[:map_bounds] = "#{latitude + 0.22},#{longitude + 0.44},#{latitude - 0.22},#{longitude - 0.44}"
    end

    bounds = map_bounds.split(",").collect { |point| point.to_f }

    params[:map_center] = "#{(bounds[0].to_f + bounds[2].to_f)/2},#{(bounds[1].to_f + bounds[3].to_f)/2}" unless params[:map_center]
    params[:map_zoom] = 9 unless params[:map_zoom]

    searchable = searchable.in_bounds(bounds[0],bounds[1],bounds[2],bounds[3])
  end

  def apply_dow(searchable, dow_obj)
    return searchable if dow_obj.blank?

    query = []
    args = {}

    dow_obj.group_by{|ds| ds.first}.each do |grp|
      day = grp.first
      hours = []

      grp.last.collect{|g| g.split(",").last}.each do |hr|
        case hr
        when "0"
          hours << (0..12).to_a
        when "1"
          hours << (11..18).to_a
        when "2"
          hours << (17..24).to_a
        end
        hours.flatten!
      end

      query << "((searchable_date_ranges.dow = :key#{day} OR EXTRACT(DOW FROM searchable_date_ranges.starts_at#{sql_interval_for_utc_offset}) = :key#{day}) AND EXTRACT(HOUR FROM searchable_date_ranges.starts_at#{sql_interval_for_utc_offset}) IN (:key_h#{day}))"
      args["key#{day}".to_sym] = day
      args["key_h#{day}".to_sym] = hours
    end

    query = query.join(" OR ")
    searchable = searchable.includes(:searchable_date_ranges).where(query, args)
  end

  def apply_from_date(searchable, from_date)
    searchable = searchable.on_or_after_date(from_date)
  end

  SIMILAR_RESULTS_LIMIT = 10
  def find_similar_results
    # => Expand Search here to find similar results
    if @messages_total_count + @events_total_count < SIMILAR_RESULTS_LIMIT
      3.times do |i|
        case i
        when 0
          # => Relax date range
          @similar_results = Searchable.explorable
          @similar_results = apply_filter(@similar_results, :from_date => nil)
        when 1
          # => Relax map radius to 100km/62miles from center
          @similar_results = Searchable.explorable

          expanded_bounds = Geocoder::Calculations.bounding_box(params[:map_center].split(",").map{|i| i.to_f}, 100, :units=>:km)
          @similar_results = apply_filter(@similar_results, :from_date => nil, :map_bounds => [expanded_bounds[2], expanded_bounds[3], expanded_bounds[0], expanded_bounds[1]].join(","))
        when 2
          # => Relax keywords
          @similar_results = Searchable.explorable
          expanded_bounds = Geocoder::Calculations.bounding_box(params[:map_center].split(",").map{|i| i.to_f}, 100, :units=>:km)
          @similar_results = apply_filter(@similar_results,
            :from_date => nil,
            :map_bounds => [expanded_bounds[2], expanded_bounds[3], expanded_bounds[0], expanded_bounds[1]].join(","),
            :keywords => nil)
        end

        @similar_results = @similar_results.where("searchables.id NOT IN(?)", @searchables.collect(&:id)) unless @searchables.empty?

        break if @similar_results.count > 50
      end

      @total_count = @similar_results.count
      @similar_results = @similar_results.limit(@per_page).offset(@offset)

    end
  end
  
  def apply_filter(search_object, args = {})
    # => Add these variables so that the params can be bypassed to expand the search
    keywords = args.key?(:keywords) ? args[:keywords] : params[:keywords]
    from_date = args.key?(:from_date) ? args[:from_date] : params[:from_date]
    prm_date_search = from_date.nil? ? nil : params[:date_search]
    to_date = args.key?(:to_date) ? args[:to_date] : params[:to_date]
    map_bounds = args.key?(:map_bounds) ? args[:map_bounds] : params[:map_bounds]

    search_object = search_object.where(:ignored => false)
    search_object = search_object.with_keywords(keywords) unless keywords.blank?

    unless(date_search = prm_date_search).blank?

      query = []
      args = {}

      date_search.group_by{|ds| ds.first}.each do |grp|
        day = grp.first
        hours = []
  
        grp.last.collect{|g| g.split(",").last}.each do |hr|
          case hr
          when "0"
            hours << (0..12).to_a
          when "1"
            hours << (11..18).to_a
          when "2"
            hours << (17..24).to_a
          end
          hours.flatten!
        end
        
        query << "((searchable_date_ranges.dow = :key#{day} OR EXTRACT(DOW FROM searchable_date_ranges.starts_at#{sql_interval_for_utc_offset}) = :key#{day}) AND EXTRACT(HOUR FROM searchable_date_ranges.starts_at#{sql_interval_for_utc_offset}) IN (:key_h#{day}))"
        args["key#{day}".to_sym] = day
        args["key_h#{day}".to_sym] = hours
      end

      query = query.join(" OR ")
      search_object = search_object.includes(:searchable_date_ranges).where(query, args)
    end

    # => By default only show events today and in the future unless a date search is specified.
    if from_date.blank? #&& to_date.blank?
      search_object = search_object.on_or_after_date(Date.today)
    else
      search_object = search_object.on_or_after_date(from_date) unless from_date.blank?
      #search_object = search_object.on_or_before_date(to_date) unless to_date.blank?
    end

    # GEO LOCATION SEARCHING
    
    # order: ne_lat, ne_lng, sw_lat, sw_lng
    # TODO: Temporary default handling for user's initial location, need to read user's location and use that LatLng here
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

        #TODO - unlogged in user coming to our site for first time...setting to toronto for now...
        latitude ||= 43.66061599944655
        longitude ||= -79.3938175316406

        params[:map_center] = "#{latitude},#{longitude}"
      end
      
      map_bounds = params[:map_bounds] = "#{latitude + 0.22},#{longitude + 0.44},#{latitude - 0.22},#{longitude - 0.44}"
    end

    bounds = map_bounds.split(",").collect { |point| point.to_f }
    
    params[:map_center] = "#{(bounds[0].to_f + bounds[2].to_f)/2},#{(bounds[1].to_f + bounds[3].to_f)/2}" unless params[:map_center]
    params[:map_zoom] = 9 unless params[:map_zoom]

    search_object = search_object.in_bounds(bounds[0],bounds[1],bounds[2],bounds[3])
    #search_object = search_object.order("searchables.created_at DESC")
    
    return search_object
  end

  def nav_state
    @on_explore = true
  end

end
