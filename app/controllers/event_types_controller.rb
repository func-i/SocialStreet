class EventTypesController < ApplicationController


  # for autocomplete on explore page
  def index
    query = params[:term]
    render :json => EventType.with_keywords(query).all.collect{|et| {:label => "#{"<img height='35' width='35' src='" + et.image_path + "' /> " if et.image_path}#{et.name}", :value => et.name}}
  end

end
