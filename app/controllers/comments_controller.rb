class CommentsController < ApplicationController

  before_filter :load_commentable_resource
  before_filter :store_comment_request, :only => [:create]
  before_filter :authenticate_user!, :only => [:create]#, :if => Proc.new { |c| !c.request.xhr? } 

  def create
    puts "SARAJOSHY"
    @success = create_comment(session[:stored_redirect][:params])
    
    if request.xhr?
      puts "HELLO JOSHY"
        render :partial => 'create'
    else
      puts "HELLO SARA"
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
