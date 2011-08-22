class Feedback < ActiveRecord::Base
  belongs_to :rsvp

  default_value_for :responded, false

  scope :by_user, lambda{ |user|
    includes(:rsvp).where(:rsvps => {:user_id => user.id})
  }
  scope :awaiting_response, lambda{
    includes(:rsvp => {:event => {:searchable => [:searchable_date_ranges] }}).where("NOT feedbacks.responded AND ((searchable_date_ranges.ends_at IS NULL AND searchable_date_ranges.starts_at < ?) OR searchable_date_ranges.ends_at < ?) ", Time.zone.now, Time.zone.now)
  }

  

end
