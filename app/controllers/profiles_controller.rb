# To change this template, choose Tools | Templates
# and open the template in the editor.

class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_user
  
  def edit
    puts "edit!!!!!!!!!!!!!!!!!!!!!!!!"
  end

  def update
    puts params[:user]
    @user.attributes = params[:user]
    if @user.save
      redirect_to edit_profile_path , :notice => "You have successfully updated your profile"
    else
      redirect_to edit_profile_path, :notice => "Error updating your profile"
    end
  end

  def require_user
    @user = current_user
  end
end
