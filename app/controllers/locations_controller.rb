class LocationsController < ApplicationController
  skip_before_filter :redirect_mobile

  def update_user_location   
    #store in session for quick access
    

    cookies.delete :cur
    if params[:latitude]
      cookies.delete :c_lat
      cookies[:c_lat] = { :value => params[:latitude], :expires => 1.day.from_now }
    end
    if params[:longitude]
      cookies.delete :c_lng
      cookies[:c_lng] = { :value => params[:longitude], :expires => 1.day.from_now }
    end
    if params[:zoom_level]
      cookies.delete :c_zoom
      cookies[:c_zoom] = { :value => params[:zoom_level], :expires => 1.day.from_now }
    end
    if params[:sw_lat]
      cookies.delete :c_sw_lat
      cookies[:c_sw_lat] = { :value => params[:sw_lat], :expires => 1.day.from_now }
    end
    if params[:sw_lng]
      cookies.delete :c_sw_lng
      cookies[:c_sw_lng] = { :value => params[:sw_lng], :expires => 1.day.from_now }
    end
    if params[:ne_lat]
      cookies.delete :c_ne_lat
      cookies[:c_ne_lat] = { :value => params[:ne_lat], :expires => 1.day.from_now }
    end
    if params[:ne_lng]
      cookies.delete :c_ne_lng
      cookies[:c_ne_lng] = { :value => params[:ne_lng], :expires => 1.day.from_now }
    end

    #store in users model if current user exists
    if (current_user && (!defined?(params[:update_db]) || true == params[:update_db]))
      current_user.update_users_location(
        params[:latitude],
        params[:longitude],
        params[:zoom_level],
        params[:sw_lat],
        params[:sw_lng],
        params[:ne_lat],
        params[:ne_lng]
      )
    end

    render :nothing => true

  end
end
