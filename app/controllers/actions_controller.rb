class ActionsController < ApplicationController

  before_filter :load_event_types, :only => [:index]
  
  def index
    # TODO: search parameters (much like with events#index) , pagination , etc - KV
    find_actions
  end

  protected

  def find_actions
    @actions = Action.top_level
    @actions = @actions.of_type(params[:types]) unless params[:types].blank?
    @actions = @actions.newest_first.all
  end

  def nav_state
    @on_events = true
  end

  def load_event_types
    @event_types ||= EventType.order('name').all
  end



end
