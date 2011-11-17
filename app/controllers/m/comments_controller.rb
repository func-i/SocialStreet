class M::CommentsController < MobileController
  before_filter :ss_authenticate_user!

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
end