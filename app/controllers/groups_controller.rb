class GroupsController < ExploreBaseController
  def show
    @group = Group.find params[:id]
    super_index
  end

end
