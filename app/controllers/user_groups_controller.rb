class UserGroupsController < ApplicationController

  before_filter :load_user_group, :only => [:update, :destroy]

  def create
    @group = Group.find params[:group_id]
    @user_group = @group.user_groups.new(params[:user_group])
    @user_group.save
  end

  def update
    @user_group.update_attributes(params[:user_group]) if @user_group
  end

  def destroy
    @user_group.destroy
  end

  protected

  def load_user_group
    @group = Group.find params[:group_id]
    @user_group = @group.user_groups.find params[:id]    
  end


end
