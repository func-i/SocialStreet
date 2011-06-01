class EventType < ActiveRecord::Base

  make_searchable :fields => %w{event_types.name}

end
