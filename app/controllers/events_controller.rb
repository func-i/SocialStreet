class EventsController < ApplicationController
  before_filter :store_current_path, :only => [:show]

  def show
    @event = Event.find params[:id]
    @comments = @event.comments
  end
end