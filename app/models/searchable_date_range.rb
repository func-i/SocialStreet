class SearchableDateRange < ActiveRecord::Base

  belongs_to :searchable

  @@dows = %w{Sunday Monday Tuesday Wednesday Thursday Friday Saturday}
  

  default_value_for :starts_at do
#    Time.zone.now.advance(:hours => 3).floor(15.minutes)
  end
  default_value_for :ends_at do |e|
#    (e.starts_at || Time.zone.now.advance(:hours => 3)).advance(:hours => 3).floor(15.minutes)
  end

  validate :valid_dates

  def to_s
    s = ""
    if dow
      s << @@dows[dow].pluralize
    end
    if start_time? && start_time > DAY_FIRST_MINUTE
      if end_time? && end_time < DAY_LAST_MINUTE
        s << " between #{start_time} and #{end_time}"
      else
        s << " after #{start_time}"
      end
    elsif end_time? && end_time < DAY_LAST_MINUTE
      " before #{end_time}"
    end
  end

  def self.dow_string(index)
    @@dows[index]
  end

  def valid_dates
    errors.add :ends_at, '^ When? end date must be after the event starts' if ends_at && ends_at <= starts_at
  end

  def matches?(date_ranges)
    !!date_ranges.detect { |dr| matches_date_range?(dr) }
  end

  def overlapping_dates_with?(date_range)
    if has_dates? && date_range.has_dates?
      dates_overlap_with?(date_range.starts_at, date_range.ends_at)
    elsif dow? && date_range.has_dates?
      date_range.starts_at.to_date.step(date_range.ends_at.to_date) {|date| return true if date.wday == dow }
      false 
    elsif has_dates? && date_range.dow?
      starts_at.to_date.step(ends_at.to_date) {|date| return true if date.wday == date_range.dow }
      false
    elsif dow? && date_range.dow?
      date_range.dow == dow
    else
      false
    end
  end

  def overlapping_times_with?(date_range)
    if has_times? && date_range.has_times?
      times_overlap_with?(date_range.start_time, date_range.end_time)
    elsif has_times? && date_range.has_dates?
      times_overlap_with?(
        (date_range.starts_at.to_i - date_range.starts_at.beginning_of_day.to_i) / 60,
        (date_range.ends_at.end_of_day.to_i - date_range.ends_at.to_i) / 60)
    elsif has_dates? && date_range.has_times?
      date_range.times_overlap_with?(
        (starts_at.to_i - starts_at.beginning_of_day.to_i) / 60,
        (ends_at.end_of_day.to_i - ends_at.to_i) / 60)
    elsif !has_times? && !date_range.has_times?
      true # they both dont have time, so they overlap fine
    end
  end

  def overlapping_with?(date_ranges)
    !!date_ranges.detect {|dr| overlapping_dates_with?(dr) && overlapping_times_with?(dr) }
  end

  def has_dates?
    (starts_at? && ends_at?)
  end

  def has_times?
    start_time? && end_time? && (start_time > DAY_FIRST_MINUTE || end_time < DAY_LAST_MINUTE)
  end

  def dates_overlap_with?(starts_at, ends_at)
    range1 = self.starts_at.to_i..self.ends_at.to_i
    range2 = starts_at.to_i..ends_at.to_i
    range1.include?(starts_at.to_i) || range1.include?(ends_at.to_i) ||
      range2.include?(self.starts_at.to_i) || range2.include?(self.ends_at.to_i)
  end

  def times_overlap_with?(start_time, end_time)
    range1 = self.start_time.to_i..self.end_time.to_i
    range2 = start_time.to_i..end_time.to_i
    range1.include?(start_time.to_i) || range1.include?(end_time.to_i) ||
      range2.include?(self.start_time.to_i)  || range2.include?(self.end_time.to_i)
  end

end
