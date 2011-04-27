class SearchSubscriptionsController < ApplicationController

  def new
    @search_subscription = SearchSubscription.new_from_params(params)
  end

  def create
    @search_subscription = SearchSubscription.new_from_params(params[:q])
    @search_subscription.user = current_user
    @search_subscription.attributes = params[:search_subscription]

    if @search_subscription.save
      flash[:notice] = "You have subscripted to this search. You will be notified when there are new events for your criteria"
      redirect_to explore_path(params[:q])
    else
      render :new
    end
  end


end
