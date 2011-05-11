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

  default_value_for :strength, 0

  default_value_for :facebook_friend, false

  COMMENT_STRENGTH_INCREASE = 1
  INVITATION_STRENGTH_INCREASE = 5
  EVENT_ATTENDANCE_STENGTH_INCREASE = 3

  def self.connect_with_users_in_action_thread(user, an_action)
    Action.threaded_with(an_action).all.each do |action|
      c = create_or_update_connection(user, action.user, COMMENT_STRENGTH_INCREASE)

      #TODO - should this work both ways? or should a connection only be created when the user initiates
      #create_connection(action.user, user)
    end
  end

  def self.connect_users_from_invitations(from_user, to_user)
    c = create_or_update_connection(from_user, to_user, INVITATION_STRENGTH_INCREASE)

    #TODO - should this work both ways
    c = create_or_update_connection(to_user, from_user, INVITATION_STRENGTH_INCREASE)
  end

  def self.connect_with_users_from_event(user, event)
    event.rsvps.attending_or_maybe_attending.all.each do |rsvp|
      c = create_or_update_connection(user, rsvp.user, EVENT_ATTENDANCE_STENGTH_INCREASE)

      #TODO - should the connection be this way? or the opposite so only ppl who didn't go end up with improper connections
    end
  end

  def self.create_or_update_connection(user, to_user, strength_increase = 0)
    return nil if user.id == to_user.id

    c = user.connections.to_user(to_user).first
    c ||= user.connections.create({:to_user => to_user})

    c.strength += strength_increase

    c.save
  end
end
