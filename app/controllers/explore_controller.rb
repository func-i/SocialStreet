class ExploreController < ApplicationController
  include Mixins::GeneralHelpers::ClassMethods
  
  before_filter :load_event_types
  before_filter :store_current_path

  def index
    #    params[:keywords] = ['Baseball', 'Hockey']
    @comment = Comment.new
    # For testing only:
    Time.zone = params[:my_tz] unless params[:my_tz].blank?

    # Use the query params to find events
    find_searchables

    #raise params.inspect

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
    
    # this executes a full search, which is bad, we want to paginate (eventually)
    @overlapping_subscriptions = @overlapping_subscriptions.all.uniq_by {|s| s.search_subscription.user_id } 
    
  end

  def find_searchables
    @searchables = Searchable.explorable

    @searchables = apply_filter(@searchables) 
    
    @per_page = 5
    
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
          @similar_results = apply_filter(@similar_results, :from_date => nil, :to_date => nil)
        when 1
          # => Relax map radius to 100km/62miles from center
          @similar_results = Searchable.explorable
          
          expanded_bounds = Geocoder::Calculations.bounding_box(params[:map_center].split(",").map{|i| i.to_f}, 100, :units=>:km)          
          @similar_results = apply_filter(@similar_results, :from_date => nil, :to_date => nil, :map_bounds => [expanded_bounds[2], expanded_bounds[3], expanded_bounds[0], expanded_bounds[1]].join(","))
        when 2
          # => Relax keywords
          @similar_results = Searchable.explorable
          expanded_bounds = Geocoder::Calculations.bounding_box(params[:map_center].split(",").map{|i| i.to_f}, 100, :units=>:km)
          @similar_results = apply_filter(@similar_results,
            :from_date => nil,
            :to_date => nil,
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

  def apply_filter(search_object, args = {})

    # => Add these variables so that the params can be bypassed to expand the search
    keywords = args.key?(:keywords) ? args[:keywords] : params[:keywords]
    from_date = args.key?(:from_date) ? args[:from_date] : params[:from_date]
    to_date = args.key?(:to_date) ? args[:to_date] : params[:to_date]
    map_bounds = args.key?(:map_bounds) ? args[:map_bounds] : params[:map_bounds]

    search_object = search_object.where(:ignored => false)
    search_object = search_object.with_keywords(keywords) unless keywords.blank?

    unless(date_search = params[:date_search]).blank?

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
      search_object = search_object.on_or_before_date(to_date) unless to_date.blank?
    end

    # GEO LOCATION SEARCHING
    
    # order: ne_lat, ne_lng, sw_lat, sw_lng
    # TODO: Temporary default handling for user's initial location, need to read user's location and use that LatLng here
    if map_bounds.blank?
      map_bounds = params[:map_bounds] = "43.958661074786455,-78.99006997304684,43.362570924106635,-79.79756509023434"
    end
    params[:map_center] = "43.66061599944655,-79.3938175316406" if params[:map_center].blank?
    params[:map_zoom] = 9 unless params[:map_zoom]
    
    bounds = map_bounds.split(",").collect { |point| point.to_f }
    search_object = search_object.in_bounds(bounds[0],bounds[1],bounds[2],bounds[3]).order("searchables.created_at DESC")    
    
    return search_object
  end

  def nav_state
    @on_explore = true
  end

end
