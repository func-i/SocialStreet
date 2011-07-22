class FeedItem
 attr_accessor :feed_type, :action_id, :event_id, :inserted_because

 @@types = {
    :event_created => 'Event Created',
    :event_rsvp => 'Event RSVP',
    :comment => 'Comment',
  }.freeze
  cattr_accessor :types

  @@reasons = {
    :subscription => 'Matched Subscription',
    :connection => 'Connection',
    :participated => 'Participated',
  }.freeze
  cattr_accessor :reasons

  def self.create_from_json(json_hash)
    f = FeedItem.new
    f.feed_type = json_hash[:feed_type]
    f.action_id = json_hash[:action_id]
    f.event_d = json_hash[:event_id]
    f.inserted_because = json_hash[:inserted_because]

    return f
  end
end
