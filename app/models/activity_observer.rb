class ActivityObserver < ActiveRecord::Observer

  observe :event

  def after_create(record)

    if record.is_a? Event
      record.activities.create :user => record.user,
        :event => record,
        :activity_type => Activity.types[:event_created]
    end

  end

end
