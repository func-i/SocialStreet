# To change this template, choose Tools | Templates
# and open the template in the editor.

class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_user

  def show

  end
  
  def edit

  end

  def update
  end

  def require_user
    @user = current_user
  end
end
