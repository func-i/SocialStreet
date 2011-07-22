class RecordType
@@types = {
  :event => "Event",
  :search_comment => "Search_Comment",
  :created_event => "Event Created",
  :profile_comment_posted => "Profile Comment Posted",
  :event_comment_posted => "Event Comment Posted",
  :search_comment_posted => "Search Comment Posted",
  :profile_comment_replied => "Profile Comment Replied",
  :event_comment_replied => "Event Comment Replied",
  :search_comment_replied => "Search Comment Replied",
  :plain_thread => "Plain Thread"
}.freeze
  cattr_accessor :types
end
