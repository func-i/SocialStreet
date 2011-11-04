class GroupsController < ExploreBaseController
  before_filter :ss_authenticate_user!, :only => [:edit, :update, :apply_for_membership]
  before_filter :load_group, :only => [:show, :edit, :update, :destroy, :show_members]

  def show
    @page_title = @group.name
    super_index
  end

  def apply_for_membership
    user_group = UserGroup.where(:group_id => params[:group_id], :user_id => current_user).limit(1)
    if user_group.length <= 0
      ug = UserGroup.new(:user_id => current_user, :group_id=> params[:group_id], :join_code => params[:group_code], :applied => true)
      ug.save
    end

    render :nothing => true
  end

  def update
    @group.attributes = params[:group]
    if @group.save
      if request.xhr?
        render :nothing => true
        return
      end

      redirect_to :action => :edit
    else
      raise 'Sorry, there was an error. We are doing our best to see that no one ever makes an error again'
    end
  end

  def search_user_groups
    unless params[:keyword].blank?
      @user_groups = UserGroup.search(params[:keyword])
    else
      @user_groups = UserGroup.all
    end
  end

  protected

  def load_group
    @group = Group.find params[:id]
  end

end
