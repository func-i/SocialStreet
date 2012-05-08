class EventPrompt < ActiveRecord::Base
  belongs_to :event

  @@answer_type_values = {
    :yes_no => 'boolean',
    :text => 'text',
    :none => 'none'
  }
  cattr_accessor :answer_type_values

  @@answer_types = [
    ['Disclaimer', EventPrompt.answer_type_values[:none]],
    ["Yes/No", EventPrompt.answer_type_values[:yes_no]],
    ["Text", EventPrompt.answer_type_values[:text]]    
  ]  
  cattr_accessor :answer_types

end
