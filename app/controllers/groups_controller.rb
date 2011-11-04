class GroupsController < ExploreBaseController
  def show
    @group = Group.find params[:id]

    @page_title = @group.name
    
    super_index
  end

  def apply_for_membership
    #TODO
  end
end
