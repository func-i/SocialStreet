class UserGroupsController < ApplicationController

  before_filter :load_user_group, :only => [:update, :destroy]

  def create
    @user_group = UserGroup.new(
      :group_id => params[:group_id],
      :external_name => params[:external_name],
      :external_email => params[:external_email],
      :join_code => params[:join_code],
      :administrator => params[:administrator],
      :applied => !params[:applied].eql?('false')
    )
    @user_group.save
  end

  def update
    @user_group.update_attributes(
      :external_name => params[:external_name],
      :external_email => params[:external_email],
      :join_code => params[:join_code],
      :administrator => params[:administrator],
      :applied => !@user_group.applied || !params[:applied].eql?('false')
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
