class LocationsController < ApplicationController

  def update_user_location
    latitude = params[:latitude].to_f
    longitude = params[:longitude].to_f
    if !(latitude.is_a?(Numeric) && !latitude.nan? && !latitude.infinite?) ||
        !(longitude.is_a?(Numeric) && !longitude.nan? && !longitude.infinite?)
    
      render :nothing => true
      return
    end

    #store in session for quick access
    cookies.delete :current_location_latitude
    cookies.delete :current_location_longitude
    
    cookies[:current_location_latitude] = { :value => latitude , :expires => 1.day.from_now }
    cookies[:current_location_longitude] = { :value => longitude, :expires => 1.day.from_now }

    #store in users model if current user exists
    current_user.update_users_location(latitude, longitude) if (current_user && (!defined?(params[:update_db]) || true == params[:update_db]))

    render :nothing => true

  end
end
