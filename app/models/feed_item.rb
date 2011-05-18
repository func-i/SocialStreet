class FeedItem
  attr_accessor :feed_type, :action_id, :event_id

 @@types = {
    :event_created => 'Event Created',
    :event_rsvp => 'Event RSVP',
    :comment => 'Comment',
  }.freeze
  cattr_accessor :types

end
