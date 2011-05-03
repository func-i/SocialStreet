class SearchableDateRange < ActiveRecord::Base

  belongs_to :searchable

  default_value_for :starts_at do
    Time.zone.now.advance(:hours => 3).floor(15.minutes)
  end
  default_value_for :ends_at do |e|
    (e.starts_at || Time.zone.now.advance(:hours => 3)).advance(:hours => 3).floor(15.minutes)
  end

  validate :valid_dates

  def valid_dates
    errors.add :ends_at, 'must be after the event starts' if ends_at && ends_at <= starts_at
  end


end
