class GroupsController < ExploreBaseController

  before_filter :load_group, :only => [:show, :edit, :update, :destroy, :show_members]

  def show
    super_index
  end

  def apply_for_membership
    #TODO
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
