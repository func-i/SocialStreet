class SearchableEventType < ActiveRecord::Base

  belongs_to :searchable
  belongs_to :event_type

end
