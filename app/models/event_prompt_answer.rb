class EventPromptAnswer < ActiveRecord::Base
  belongs_to :event_prompt
  belongs_to :event_rsvp  
end
