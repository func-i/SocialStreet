class SessionsController < Devise::SessionsController

  layout 'sign'

  def new
    redirect_to '/auth/facebook'
  end

  
end
