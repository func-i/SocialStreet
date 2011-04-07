class ActivitiesController < ApplicationController


  def index
    # TODO: search parameters (much like with events#index) , pagination , etc - KV
    @activities = Activity.newest_first.top_level.all
  end


end
