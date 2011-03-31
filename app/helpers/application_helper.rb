module ApplicationHelper

  def address_for(location)
    "#{location.street} #{location.city}, #{location.state}"
  end

  def display_date_time(time)
    time.to_s(:date_with_day)
  end

end
