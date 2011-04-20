class ActivitiesController < ApplicationController

  before_filter :load_event_types, :only => [:index]
  
  def index
    # TODO: search parameters (much like with events#index) , pagination , etc - KV
    find_activities
  end

  protected

  def find_activities
    @activities = Activity.top_level

    @activities = @activities.of_type(params[:types]) unless params[:types].blank?
    

    @activities = @activities.newest_first.all
  end

  def nav_state
    @on_events = true
  end

  def load_event_types
    @event_types ||= EventType.order('name').all
  end



end
