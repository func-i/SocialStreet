class ProfilesController < ApplicationController
  before_filter :ss_authenticate_user!, :only => [:edit, :update, :add_group]
  before_filter :store_add_group_redirect, :only => [:add_group]

  def edit
    @user = current_user

    puts @user.inspect

    @groups = Group.all
    
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

  def add_group
    @user = current_user
    @group = Group.find params[:group_id]
    
    if @group.join_code_description.blank?
      puts "BLANK"
      user_group = UserGroup.where(:group_id => @group, :user_id => @user).limit(1)
      if user_group.length <= 0
        user_group = UserGroup.new
        user_group.user = @user
        user_group.group = @group
        user_group.applied = false
        user_group.save
      elsif user_group.applied
        user_group.applied = false
        user_group.save
      end

      #render :nothing => true
    else
      puts "NOT BLANK"
      #Validate group code
      if @group.is_code_valid(params[:group_code])
        puts "VALID"
        #Check user_group table for group_id & group_code and user_id is empty
        user_group = UserGroup.where(:group_id => @group, :join_code => params[:group_code]).limit(1).first
        user_group.user = @user
        user_group.applied = false
        user_group.save

        @success = true
      else
        puts "NOT VALID"
        #throw error
        @success = false
      end
    end
  end

  def socialcard
    @user = User.find params[:id]
    render :layout => false
  end

  protected

  def store_add_group_redirect
    store_redirect(:controller => 'profiles', :action => 'add_group', :params => params)
  end
end