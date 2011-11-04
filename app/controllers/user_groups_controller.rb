class UserGroupsController < ApplicationController

  def update
    @group = Group.find params[:group_id]
    @user_group = @group.user_groups.find params[:id]
    @user_group.update_attributes(params[:user_group]) if @user_group    
  end
end
