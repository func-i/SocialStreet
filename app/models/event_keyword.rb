class EventKeyword < ActiveRecord::Base
  belongs_to :event
  belongs_to :event_type

  before_save :reference_correct_event_type # in case a synonym was specified

  protected

  def reference_correct_event_type
    if self.event_type && self.event_type.synonym
      self.event_type = self.event_type.synonym
    end
  end

end
