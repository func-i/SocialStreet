class AuthenticationsController < ApplicationController

  def index
    @authentications = current_user.authentications if current_user
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to authentications_url
  end

  def create
    auth = request.env['omniauth.auth']
    authentication = Authentication.find_by_provider_and_uid(auth['provider'], auth['uid'])
    if authentication
      flash[:notice] = "Welcome back #{authentication.user.name}"
      sign_in_and_redirect(:user, authentication.user)
    elsif current_user
      current_user.authentications.create!(:provider => auth['provider'], :uid => auth['uid'])
      flash[:notice] = "Added #{auth['provider']} access to your account"
      redirect_to root_url
    else
      user = User.new
      user.apply_omniauth(auth)
      if user.save
        flash[:notice] = 'Hello and welcome to SocialStreet'
        sign_in_and_redirect(:user, user)
      else
        session[:omniauth] = auth.except('extra')
        flash[:warning] = 'Everything looks good, but we still need some more information from you next'
        redirect_to new_user_registration_url
      end
    end
    
  end

end
