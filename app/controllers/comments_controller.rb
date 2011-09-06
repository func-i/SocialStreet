class CommentsController < ApplicationController

  before_filter :load_commentable_resource
  before_filter :store_comment_request, :only => [:create]
  before_filter :ss_authenticate_user!, :only => [:create, :destroy]#, :if => Proc.new { |c| !c.request.xhr? }

  def create
    @success = create_comment(session[:stored_redirect][:params])
    
    if request.xhr?
      render :partial => 'create'
    else
      redirect_to stored_path
      #redirect_to stored_path, :notice => "Thank you for your generous comment"
    end    
  end

  def destroy
    comment_to_destroy = Comment.find(params[:id])
    return unless comment_to_destroy

    unless comment_to_destroy.action.actions.empty?
      searchable_to_save = comment_to_destroy.action.searchable
      comment_to_destroy.action.actions.first.reference.searchable = searchable_to_save
    end

    comment_to_destroy.destroy
    
    if request.xhr?
      render :nothing => true
    else
      redirect_to stored_path
    end
  end

  protected

  def store_comment_request
    store_redirect(:controller => 'comments', :action => 'create', :params => params)
  end

  def load_commentable_resource
    @commentable = Event.find params[:event_id].to_i if params[:event_id]
    @commentable = Action.find params[:action_id].to_i if params[:action_id]
    @commentable = User.find params[:profile_id].to_i if params[:profile_id]
  end

end
