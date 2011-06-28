class ExploreController < ApplicationController

  before_filter :load_event_types
  before_filter :store_current_path

  def index
    #    params[:keywords] = ['Baseball', 'Hockey']
    @comment = Comment.new
    # For testing only:
    Time.zone = params[:my_tz] unless params[:my_tz].blank?

    # Use the query params to find events
    find_searchables

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

    @per_page = 10
    @offset = ((params[:page] || 1).to_i * @per_page) - @per_page
    @total_count = @searchables.count
    @searchables = @searchables.limit(@per_page).offset(@offset)
    @num_pages = (@total_count.to_f / @per_page.to_f).ceil

  end

  def apply_filter(search_object)

    #search_object = search_object.where(:ignored => false)
    search_object = search_object.with_keywords(params[:keywords]) unless params[:keywords].blank?

    search_object = search_object.on_days_or_in_date_range(params[:days], params[:from_date], params[:to_date], params[:inclusive])

    # to_time and from_time are in integer (minute) format. 1439 = 11:59 PM (the day has 1440 minutes) - KV
    search_object = search_object.at_or_after_time_of_day(params[:from_time].to_i) 
    search_object = search_object.at_or_before_time_of_day(params[:to_time].to_i) if params[:to_time] && params[:to_time].to_i < DAY_LAST_MINUTE

    # => By default only show events today and in the future unless a date search is specified.
    if params[:from_date].blank? && params[:to_date].blank?
      #search_object = search_object.on_or_after_date(Date.today)
    else
      search_object = search_object.on_or_after_date(params[:from_date]) unless params[:from_date].blank?
      search_object = search_object.on_or_before_date(params[:to_date]) unless params[:to_date].blank?
    end

    # GEO LOCATION SEARCHING
    
    # order: ne_lat, ne_lng, sw_lat, sw_lng
    # TODO: Temporary default handling for user's initial location, need to read user's location and use that LatLng here
    if params[:map_bounds].blank?
      params[:map_bounds] = "43.958661074786455,-78.99006997304684,43.362570924106635,-79.79756509023434"
    end
    params[:map_center] = "43.66061599944655,-79.3938175316406" if params[:map_center].blank?
    params[:map_zoom] = 9 unless params[:map_zoom]

    bounds = params[:map_bounds].split(",").collect { |point| point.to_f }
    search_object = search_object.in_bounds(bounds[0],bounds[1],bounds[2],bounds[3]).order("searchables.created_at DESC")    
    
    return search_object
  end

  def nav_state
    @on_explore = true
  end

end
