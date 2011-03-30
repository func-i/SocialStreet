module ApplicationHelper

  def address_for(location)
    "#{location.street} #{location.city}, #{location.state}"
  end

end
