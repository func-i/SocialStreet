class EventGroup < ActiveRecord::Base
  belongs_to :group
  belongs_to :event

  def pseudo_group_id=(id)
    if id == 'public'
      self.group_id = nil
    else
      self.group_id = id
    end
  end
end
