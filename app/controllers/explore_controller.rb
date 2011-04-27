class ExploreController < ApplicationController

  before_filter :load_event_types
  before_filter :store_current_path

  def index
    @comment = Comment.new
    # For testing only:
    Time.zone = params[:my_tz] unless params[:my_tz].blank?

    # Use the query params to find events (ideally this should be ONE SQL query with pagination)
    find_searchables
  end

  protected

  def load_event_types
    @event_types ||= EventType.order('name').all
  end

  def find_searchables
    @searchables = Searchable.with_excludes_for_explore

    radius = params[:radius].blank? ? 20 : params[:radius].to_i

    @searchables = @searchables.with_event_types(params[:types]) unless params[:types].blank?

    @searchables = @searchables.on_days_or_in_date_range(params[:days], params[:from_date], params[:to_date], params[:inclusive])

    # to_time and from_time are in integer (minute) format. 1439 = 11:59 PM (the day has 1440 minutes) - KV
    @searchables = @searchables.at_or_after_time_of_day(params[:from_time].to_i) if params[:from_time] && params[:from_time].to_i > 0
    @searchables = @searchables.at_or_before_time_of_day(params[:to_time].to_i) if params[:to_time] && params[:to_time].to_i < 1439

    # GEO LOCATION SEARCHING
    unless params[:location].blank?
      group_by = Searchable.columns.map { |c| "searchables.#{c.name}" }.join(',')
      group_by += ',' + SearchableEventType.columns.map { |c| "searchable_event_types.#{c.name}" }.join(',') unless params[:types].blank?
      if params[:days] || params[:from_day] || params[:to_day] ||
          (params[:to_time] && params[:to_time].to_i < 1439) ||
          (params[:from_time] && params[:from_time].to_i > 0)
        group_by += ',' + SearchableDateRange.columns.map { |c| "searchable_date_ranges.#{c.name}" }.join(',') 
      end
      @searchables = @searchables.near(params[:location], radius, :select => "searchables.*").group(group_by)
    end

    @searchables = @searchables.all # this executes a full search, which is bad, we want to paginate (eventually) - KV
  end

  def nav_state

      @on_explore = true

  end

end
