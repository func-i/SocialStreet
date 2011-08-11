class SessionsController < Devise::SessionsController

  layout 'sign'

  def new
    respond_to do |format|
      format.js do
        render :update do |page|
          page.redirect_to '/auth/facebook'
        end
      end
      format.html do
        redirect_to '/auth/facebook'
      end
    end
    
    
  end
end
