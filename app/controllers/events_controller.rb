class EventsController < ApplicationController
  def show
    @event = Event.find params[:id]
    @comments = @event.comments
  end
end