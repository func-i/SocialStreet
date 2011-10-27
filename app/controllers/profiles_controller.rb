class ProfilesController < ApplicationController
  before_filter :ss_authenticate_user!, :only => [:edit, :update]

  def edit
    @user = current_user
    
    if request.xhr?
      render "shared/ajax_load.js", :locals => {:file_name_var => 'profiles/edit.html.erb'}
    end
  end

  def update
    @user = current_user

    @user.attributes = params[:user]
    if @user.save
      if request.xhr?
        render :nothing => true
        return
      end

      redirect_to :action => :edit
    else
      raise 'Sorry, there was an error. We are doing our best to see that no one ever makes an error again'
    end
  end
end