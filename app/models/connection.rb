class Connection < ActiveRecord::Base

  make_searchable :fields => %w{users.first_name users.last_name users.email}, :include => [:to_user]

  belongs_to :user
  belongs_to :to_user, :class_name => "User"

  scope :to_user, lambda { |user| where(:to_user_id => user.id) }

  scope :most_relevant_first, order("connections.strength DESC, connections.updated_at DESC")

  scope :common_with_ordered_by_strength, lambda{ |user|
    joins("INNER JOIN connections AS joined_connections
       ON joined_connections.to_user_id = connections.to_user_id AND joined_connections.user_id = #{user.id}"
    ).order(
      "connections.strength * connections.strength * joined_connections.strength DESC"
    )
 }

      "INNER JOIN rsvps AS joined_rsvps ON joined_rsvps.event_id = rsvps.event_id AND joined_rsvps.user_id = #{user.id}"

  default_value_for :strength, 1

  default_value_for :facebook_friend, false

end
