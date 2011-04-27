class ActionObserver < ActiveRecord::Observer

  observe :event, :rsvp, :comment

  def after_create(record)

    if record.is_a? Event
      record.actions.create :user => record.user,
        :action_type => Action.types[:event_created],
        :action => record.action
    elsif record.is_a?(Rsvp) && record.status == Rsvp.statuses[:attending]
      record.event.actions.create :user => record.user,
        :action_type => Action.types[:event_rsvp_attending],
        :reference => record
    elsif record.is_a?(Comment)
      if record.commentable.is_a?(Event)
        record.commentable.actions.create :user => record.user,
          :action_type => Action.types[:event_comment],
          :reference => record
      elsif record.commentable.is_a?(Action)
        record.commentable.actions.create :user => record.user,
          :action_type => Action.types[:action_comment],
          :reference => record
      elsif record.commentable.nil? # global search filter
        Action.create :user => record.user,
          :action_type => Action.types[:search_comment],
          :reference => record
      end
    end
  end

  def before_update(record)
    if record.is_a?(Rsvp) && record.status_changed? && record.status == Rsvp.statuses[:attending]
      unless record.actions.where(:action_type => Action.types[:event_rsvp_attending], :user_id => record.user.id).first
        record.event.actions.create :user => record.user,
          :action_type => Action.types[:event_rsvp_attending],
          :reference => record
      end
    end
  end

end
