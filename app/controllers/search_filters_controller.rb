class SearchFiltersController < ApplicationController

  
  def create
    @search_filter = SearchFilter.new_from_params(params)
    @search_filter.user = current_user

    if @search_filter.save
      render :text => @search_filter.inspect
    else
      render :text => @search_filter.errors.full_messages.inspect # shouldn't really ever go in here unless there's a bug or something unexpected
    end
  end


end
