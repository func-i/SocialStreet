class SessionsController < Devise::SessionsController

  layout 'sign'

  def new
    respond_to do |format|
      format.js 
      format.html do
        redirect_to '/auth/facebook'
      end
    end    
  end

#  def destroy
 #   puts "JOSHY IS HERE"
 # end
  
end
