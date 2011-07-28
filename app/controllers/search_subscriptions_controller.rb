class SearchSubscriptionsController < ApplicationController

  before_filter :store_subscription_request, :only => [:create]
  #before_filter :store_current_path, :only => [:new]
  before_filter :authenticate_user!, :only => [:create]


  def new
    puts "JOSHY NEW"
    @search_subscription = SearchSubscription.new_from_params(params)
  end

  def create
    puts "JOSHY CREATE"

    if create_search_subscription(params)
      redirect_to :back
    else
      render :new
    end
    
    #
    #    @search_subscription = SearchSubscription.new_from_params(params[:q])
    #    @search_subscription.user = current_user
    #    @search_subscription.attributes = params[:search_subscription]
    #
    #    if @search_subscription.save
    #      redirect_to :back
    #    else
    #      render :new
    #    end
  end

  def destroy
    @search_subscription = SearchSubscription.find params[:id]
    if @search_subscription.destroy
      redirect_to :back
    else
      raise "WHAT THE F***"
    end
  end

  protected

  def store_subscription_request
    store_redirect(:controller => 'search_subscriptions', :action => 'create', :params => params)
  end



end
