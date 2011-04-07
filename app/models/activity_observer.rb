class ActivityObserver < ActiveRecord::Observer

  observe :event, :rsvp, :comment

  def after_create(record)

    if record.is_a? Event
      record.activities.create :user => record.user,
        :activity_type => Activity.types[:event_created],
        :activity => record.activity
    elsif record.is_a?(Rsvp) && record.status == Rsvp.statuses[:attending]
      record.event.activities.create :user => record.user,
        :activity_type => Activity.types[:event_rsvp_attending],
        :reference => record
    elsif record.is_a?(Comment)
      if record.commentable.is_a?(Event)
        record.commentable.activities.create :user => record.user,
          :activity_type => Activity.types[:event_comment],
          :reference => record
      elsif record.commentable.is_a?(Activity)
        record.commentable.activities.create :user => record.user,
          :activity_type => Activity.types[:activity_comment],
          :reference => record
      end
    end
  end

  def before_update(record)
    if record.is_a?(Rsvp) && record.status_changed? && record.status == Rsvp.statuses[:attending]
      unless record.activities.where(:activity_type => Activity.types[:event_rsvp_attending], :user_id => record.user.id).first
        record.event.activities.create :user => record.user,
          :activity_type => Activity.types[:event_rsvp_attending],
          :reference => record
      end
    end
  end

end
