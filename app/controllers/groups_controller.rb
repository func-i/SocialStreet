class GroupsController < ExploreBaseController
  def show
    @group = Group.find params[:id]
    super_index
  end

  def apply_for_membership
    
  end
end
