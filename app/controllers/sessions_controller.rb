class SessionsController < Devise::SessionsController

  layout 'sign'

  def new
    if request.xhr?
      render :update do |page|
        page.redirect_to '/auth/facebook', :status => 401
      end
    else
      redirect_to '/auth/facebook', :status => 401
    end
    
  end
end
