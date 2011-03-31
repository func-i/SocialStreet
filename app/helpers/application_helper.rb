module ApplicationHelper

  def address_for(location)
    "#{location.street} #{location.city}, #{location.state}"
  end

  def display_date_time(time)
    time.to_s(:date_with_day) + " at " + time.to_s(:time12h) + " #{Time.zone.now.zone}"
  end

end
