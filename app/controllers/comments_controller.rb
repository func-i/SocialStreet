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
    if comment_to_destroy.nil?
      render :nothing => true
      return
    end
    
    index = -1
    next_head_comment = nil
    while next_head_comment.nil? do
      index = index + 1
      next_head_comment = comment_to_destroy.action.actions[index].try(:reference)
      if comment_to_destroy.action.actions.length < index
        comment_to_destroy.destroy
        render :nothing => true
        return
      end
    end
    next_head_comment = comment_to_destroy.action.actions[index].reference
    next_head_comment.commentable = nil
    next_head_comment.searchable = comment_to_destroy.searchable
    next_head_comment.save

    next_head_comment.action.action_type = comment_to_destroy.action.action_type
    next_head_comment.action.to_user = comment_to_destroy.action.to_user
    next_head_comment.action.action = nil
    next_head_comment.action.actions = comment_to_destroy.action.actions
    next_head_comment.action.actions.slice!(index)
    next_head_comment.action.save
      
    comment_to_destroy.searchable = nil
    comment_to_destroy.save

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
