class FeedObserver < ActiveRecord::Observer

  observe :action

  def after_create(action)
    Resque.enqueue(Jobs::ProcessNewAction, action.id)
  end

end
