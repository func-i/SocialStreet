class CommentsController < ApplicationController

  before_filter :load_commentable_resource
  before_filter :store_comment_request, :only => [:create]
  before_filter :authenticate_user!, :only => [:create]#, :if => Proc.new { |c| !c.request.xhr? } 

  def create
    @success = create_comment(session[:stored_redirect][:params])

    puts @comment.inspect
    puts params.inspect
    
    if request.xhr?
        render :partial => 'create'
    else
      redirect_to stored_path
      #redirect_to stored_path, :notice => "Thank you for your generous comment"
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
