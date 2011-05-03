class LocationsController < ApplicationController

  # assume ajax / json for now (it's bad practice but this is prototype code) - KV
  def index
    @locations = Location.searched_by(current_user, params[:query], 
      [params[:lat], params[:lng]],
      (params[:radius] || 50).to_i).limit(10).all
    
    render :json => @locations.collect {|loc| {
        :id => loc.id,
        :text => loc.text,
        :latitude => loc.latitude,
        :longitude => loc.longitude
      }
    }
  end

end
