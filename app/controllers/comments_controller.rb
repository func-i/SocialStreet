class CommentsController < ApplicationController

  before_filter :load_commentable_resource
  before_filter :store_comment_request, :only => [:create]
  before_filter :authenticate_user!, :only => [:create]

  def create
    if create_comment(session[:stored_redirect][:params])
      redirect_to stored_path
    else
      raise 'shit, what happened'
    end
  end

  protected

  def store_comment_request
    store_redirect(:controller => 'comments', :action => 'create', :params => params)
  end

  def load_commentable_resource
    @commentable = Event.find params[:event_id].to_i if params[:event_id]
    @commentable = Action.find params[:action_id].to_i if params[:action_id]
  end

end
