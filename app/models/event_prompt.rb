class EventPrompt < ActiveRecord::Base
  belongs_to :event

  @@answer_types = [
    ["boolean"],
    ["text"]
  ]
  
  cattr_accessor :answer_types

end
