class EventsController < ApplicationController
  before_filter :store_current_path, :only => [:show]

  def show
    @event = Event.find params[:id]
    @comments = @event.comments.order('created_at DESC').all

    @invitation_user_connections = current_user.connections.includes(:to_user).order("connections.strength DESC NULLS LAST, users.last_name ASC").all if current_user

    @comment = @event.comments.build
  end

  def new
    @event_types = EventType.order('name').all
    @event_for_create = Event.new
  end
end