# To change this template, choose Tools | Templates
# and open the template in the editor.

class ProfilesController < ApplicationController
  before_filter :authenticate_user!, :only => [:edit, :update]
  before_filter :require_user
  before_filter :require_permission, :only => [:edit, :update]

  def show
  end
  
  def edit
  end

  def update
    @user.attributes = params[:user]
    if @user.save
      redirect_to edit_profile_path , :notice => "You have successfully updated your profile"
    else
      redirect_to edit_profile_path, :notice => "Error updating your profile"
    end
  end

  def require_user
    @user = User.find params[:id]
  end

  def require_permission
    raise ActiveRecord::RecordNotFound if !@user.editable_by?(current_user)
  end

end
