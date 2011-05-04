class ExploreController < ApplicationController

  before_filter :load_event_types
  before_filter :store_current_path

  def index
    @comment = Comment.new
    # For testing only:
    Time.zone = params[:my_tz] unless params[:my_tz].blank?

    # Use the query params to find events (ideally this should be ONE SQL query with pagination)
    find_searchables
    find_overlapping_subscriptions
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
    @searchables = Searchable.with_excludes_for_explore

    @searchables = apply_filter(@searchables)

    @searchables = @searchables.all # this executes a full search, which is bad, we want to paginate (eventually) - KV
  end

  def apply_filter(search_object)
    radius = params[:radius].blank? ? 20 : params[:radius].to_i

    search_object = search_object.with_event_types(params[:types]) unless params[:types].blank?

    search_object = search_object.on_days_or_in_date_range(params[:days], params[:from_date], params[:to_date], params[:inclusive])

    # to_time and from_time are in integer (minute) format. 1439 = 11:59 PM (the day has 1440 minutes) - KV
    search_object = search_object.at_or_after_time_of_day(params[:from_time].to_i) if params[:from_time] && params[:from_time].to_i > 0
    search_object = search_object.at_or_before_time_of_day(params[:to_time].to_i) if params[:to_time] && params[:to_time].to_i < 1439

    # GEO LOCATION SEARCHING

    # TODO: Temporary default handling for user's initial location
    if params[:location].blank?
      params[:location] = "43.7427662,-79.3922001"
      params[:radius] = 14
    end

    group_by = Searchable.columns.map { |c| "searchables.#{c.name}" }.join(',')
    group_by += ',' + SearchableEventType.columns.map { |c| "searchable_event_types.#{c.name}" }.join(',') unless params[:types].blank?

    if !params[:days].blank? || !params[:from_date].blank? || !params[:to_date].blank? ||
        (!params[:to_time].blank? && params[:to_time].to_i < 1439) ||
        (!params[:from_time].blank? && params[:from_time].to_i > 0)
      group_by += ',' + SearchableDateRange.columns.map { |c| "searchable_date_ranges.#{c.name}" }.join(',')
    end
    search_object = search_object.near(params[:location], radius, :select => "searchables.*", :order => "searchables.created_at DESC").group(group_by)

    return search_object
  end

  def nav_state
    @on_explore = true
  end

end
