class ExploreController < ExploreBaseController
  before_filter :store_current_path, :only => [:index]
  before_filter Proc.new{ @file_var_name = 'explore/index.html.erb' }

  def index
    @page_title = "Explore"
    super_index
  end

  def search
    super_search
  end

end
