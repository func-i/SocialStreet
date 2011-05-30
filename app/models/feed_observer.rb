class FeedObserver < ActiveRecord::Observer

  observe :action

  def after_create(action)
    Resque.enqueue(Jobs::ProcessNewAction, action.id)

#
#    if action.comment_to_someone?
#      if action.sub_action?
#        # sub comment (reply) on someone's wall
#      else
#        # top level comment on someone's wall
#      end
#    elsif action.comment_to_event?
#      if action.sub_action?
#        # sub comment (reply) on event wall
#      else
#        # top level comment on event wall
#      end
#    elsif action.event_creation?
#      if action.sub_action?
#        # event created within a thread
#      else
#        # event created normally
#      end
#    end
#

  end

end
