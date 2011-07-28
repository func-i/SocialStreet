class SearchSubscriptionsController < ApplicationController

  before_filter :store_subscription_request, :only => [:create]
  #before_filter :store_current_path, :only => [:new]
  before_filter :authenticate_user!, :only => [:create]


  def new
    @search_subscription = SearchSubscription.new_from_params(params)
  end

  def create
    if create_search_subscription(params)
      render :update do |page|
        page.redirect_to :back, :notice => "You will be notified when new content is created"
      end
    else
      render :update do |page|
        page.redirect_to :back, :notice => "You need to specify a name"
      end
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
