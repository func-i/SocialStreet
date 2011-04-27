class SearchSubscriptionsController < ApplicationController

  def new
    @search_subscription = SearchSubscription.new_from_params(params)
  end

  def create
    @search_subscription = SearchSubscription.new_from_params(params[:q])
    @search_subscription.user = current_user
    @search_subscription.attributes = params[:search_subscriptions]

    if @search_subscription.save
      flash[:notice] = "You have subscripted to this search. You will be notified when there are new events for your criteria"
      redirect_to explore_path(params[:q])
    else
      render :text => @search_subscription.errors.full_messages.inspect # shouldn't really ever go in here unless there's a bug or something unexpected
    end
  end


end
