class EventTypesController < ApplicationController


  # for autocomplete on explore page
  def index
    query = params[:term]
    render :json => EventType.with_keywords(query).all.collect(&:name)
  end

end
