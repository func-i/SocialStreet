class LocationsController < ApplicationController

  def update_user_location   
    #store in session for quick access
    cookies.delete :current_location_latitude
    cookies.delete :current_location_longitude
    cookies[:current_location_latitude] = { :value => params[:latitude], :expires => 1.day.from_now }
    cookies[:current_location_longitude] = { :value => params[:longitude], :expires => 1.day.from_now }
    cookies[:current_location_zoom] = { :value => params[:zoom_level], :expires => 1.day.from_now } if params[:zoom_level]

    #store in users model if current user exists
    current_user.update_users_location(params[:latitude], params[:longitude], params[:zoom_level]) if (current_user && (!defined?(params[:update_db]) || true == params[:update_db]))

    render :nothing => true

  end
end
