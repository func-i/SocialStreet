class AuthenticationsController < ApplicationController
  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    #flash[:notice] = "Successfully destroyed authentication."
    redirect_to authentications_url
  end

  def create
    auth = request.env['omniauth.auth']
    authentication = Authentication.find_by_provider_and_uid(auth['provider'], auth['uid'])
      
    if authentication
      #flash[:notice] = "Welcome back #{authentication.user.name}"
      sign_in_and_redirect(:user, authentication.user)
    elsif current_user
      current_user.apply_omniauth(auth)
      current_user.save!
      #flash[:notice] = "Added #{auth['provider']} access to your account"
      redirect_to root_url # TODO: redirect to last location (check Devise docs)
    elsif auth['provider'] == 'facebook' && user = User.find_by_fb_uid(auth['uid'])
      user.apply_omniauth(auth)
      user.save!
      #flash[:notice] = 'Hello and welcome to SocialStreet. We had you in our DB already.'
      sign_in_and_redirect(:user, user)
    else
      user = User.new
      user.apply_omniauth(auth)
      if user.save
        #flash[:notice] = 'Hello and welcome to SocialStreet'
        sign_in_and_redirect(:user, user)
      else
        session[:omniauth] = auth.except('extra')
        #flash[:warning] = 'Everything looks good, but we still need some more information from you next'
        redirect_to new_user_registration_url
      end
    end
    
  end


  def tnc_accepted
    unless current_user
      render :text => "ERROR", :status => "500"
      return
    end

    current_user.update_attribute("accepted_tncs", true)

    Resque.enqueue(Jobs::Email::EmailUserWelcomeNotice, current_user.id)

    if params[:facebook] == '1'
      current_user.post_to_facebook_wall(
        :picture => 'http://www.socialstreet.com/images/app_icon_facebook.png',
        :link => "http://www.socialstreet.com/",
        :name => "SocialStreet.com",
        :caption => "Explore real life!",
        :description => 'SocialStreet\'s mission is to make it easy to discover friends that enjoy the same things as you! By attending and organizing "StreetMeets", you are sure to discover that you are surrounded by people just like you!',
        :message => "I just joined SocialStreet!",
        :type => "link"
      )
    end

    redirect_to after_sign_in_path_for(current_user.reload)
  end
  
end
