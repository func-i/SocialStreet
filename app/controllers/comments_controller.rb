class CommentsController < ApplicationController

  before_filter :authenticate_user!, :only => [:create]
  before_filter :load_commentable_resource

  def create
    @comment = @commentable.comments.build params[:comment]
    @comment.user = current_user

    if @comment.save
      redirect_to :back, :notice => "Comment added"
    else
      raise "shit, what now?"
    end
  end

  protected

  def load_commentable_resource
    @commentable = Event.find params[:event_id].to_i if params[:event_id]
  end

end
