class EventsController < ApplicationController
  before_filter :store_current_path, :only => [:show]

  def show
    @event = Event.find params[:id]
    @comments = @event.comments.order('created_at DESC').all

    @comment = @event.comments.build
  end

  def new
    @event_types = EventType.order('name').all
    @event_for_create = Event.new
  end
end