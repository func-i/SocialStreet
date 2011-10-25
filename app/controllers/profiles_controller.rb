class ProfilesController < ApplicationController
  before_filter :ss_authenticate_user!, :only => [:edit]

  def edit
    @user = current_user
    
    if request.xhr?
      render "shared/ajax_load.js", :locals => {:file_name_var => 'profiles/edit.html.erb'}
    end
  end
end