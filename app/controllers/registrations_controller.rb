class RegistrationsController < Devise::RegistrationsController

  layout 'sign'

  def create
    super
    session[:omniauth] = nil unless @user.new_record?
  end

  protected

  def build_resource(*args)
    super
    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
      @user.valid?
    end
  end

end
