class CommentsController < ApplicationController
  before_filter :store_comment_request, :only => [:create]
  before_filter :ss_authenticate_user!, :only => [:create]
  
  def create
    if create_comment(params[:event_id].to_i, params[:comment][:body])
      if request.xhr?
        render :partial => 'create'
      else
        raise "error"
      end
    else
      render :nothing => true
    end
  end

  def destroy
    comment = Comment.find params[:id]
    comment.destroy if comment
    render :nothing => true
  end

  protected

  def store_comment_request
    store_redirect(:controller => 'comments', :action => 'create', :params => params)
  end

end