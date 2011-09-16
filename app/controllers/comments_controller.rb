class CommentsController < ApplicationController
  before_filter :store_comment_request, :only => [:create]
  before_filter :ss_authenticate_user!, :only => [:create]
  
  def create
    event = Event.find params[:event_id]
    if event
      @comment = Comment.new params[:comment]
      @comment.event = event
      @comment.user = current_user

      if @comment.save
        #TODO - email event admin
        #TODO - connect users (does this apply since to threading?)

        if request.xhr?
          render :partial => 'create'
        else
          raise "error"
        end
      end
    else
      render :nothing => true
    end
  end

  protected

  def store_comment_request
    store_redirect(:controller => 'comments', :action => 'create', :params => params)
  end

end