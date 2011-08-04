class LocationsController < ApplicationController

  # assume ajax / json for now (it's bad practice but this is prototype code) - KV
  def index
    @locations = Location.searched_by(current_user, params[:query], 
      params[:ne_lat].to_f, params[:ne_lng].to_f, params[:sw_lat].to_f, params[:sw_lng].to_f).limit(10).all
    
    render :json => @locations.collect {|loc| {
        :id => loc.id,
        :text => loc.text,
        :latitude => loc.latitude,
        :longitude => loc.longitude
      }
    }
  end

  def update_users_location
    #store in session for quick access
    cookies[:current_location_latitude] = params[:latitude]
    cookies[:current_location_longitude] = params[:longitude]

    #store in users model if current user exists
    current_user.update_users_location(params[:latitude], params[:longitude]) if current_user

    #TODO - update


    render :nothing => true
  end


end
