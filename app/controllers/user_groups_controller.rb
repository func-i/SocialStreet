class UserGroupsController < ApplicationController

  before_filter :load_user_group

  def update
    @user_group.update_attributes(
      :external_name => params[:external_name],
      :external_email => params[:external_email],
      :join_code => params[:join_code],
      :administrator => params[:administrator]
    ) if @user_group
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
