class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :restricted
  
  protected

  def restricted
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == "ssusername" && password == "sspassword"
    end if Rails.env.production?
  end

end
