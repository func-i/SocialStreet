class Connection < ActiveRecord::Base

  make_searchable :fields => %w{users.first_name users.last_name users.email}, :include => [:to_user]

  belongs_to :user
  belongs_to :to_user, :class_name => "User"

  before_save :set_rank

  scope :to_user, lambda { |user| where(:to_user_id => user.id) }
  scope :to_user_id, lambda { |user_id| where(:to_user_id => user_id) }

  scope :most_relevant_first, order("connections.strength DESC, connections.updated_at DESC")

  scope :common_with, lambda{ |user|
    joins("INNER JOIN connections AS joined_connections
       ON joined_connections.to_user_id = connections.to_user_id AND joined_connections.user_id = #{user.id} AND joined_connections.to_user_id <> connections.user_id"
    )
  }

  scope :common_with_through_facebook, lambda{ |user|
    joins("INNER JOIN connections AS joined_connections
       ON joined_connections.to_user_id = connections.to_user_id AND joined_connections.user_id = #{user.id} AND joined_connections.to_user_id <> connections.user_id").
    where("joined_connections.facebook_friend = true AND connections.facebook_friend = true")
  }

  scope :to_user_is_member, lambda {
    joins("INNER JOIN users AS joined_users ON connections.to_user_id = joined_users.id AND joined_users.sign_in_count > 0")
  }


  scope :ranked_less_or_eq, lambda { |rank| where("connections.rank <= ?", rank)}

  default_value_for :strength, 0

  default_value_for :facebook_friend, false

  COMMENT_STRENGTH_INCREASE = 1
  EVENT_ATTENDANCE_STENGTH_INCREASE = 3
  INVITATION_STRENGTH_INCREASE = 5

  def self.connect_with_users_in_action_thread(user, an_action)
    Action.threaded_with(an_action).all.each do |action|
      c = create_or_update_connection(user, action.user, COMMENT_STRENGTH_INCREASE)

      #TODO - should this work both ways? or should a connection only be created when the user initiates
      c = create_or_update_connection(action.user, user, 0)
    end
  end

  def self.connect_users_from_invitations(from_user, to_user)
    c = create_or_update_connection(from_user, to_user, INVITATION_STRENGTH_INCREASE)

    #TODO - should this work both ways? if i'm invited by someone, does that make me closer?
    c = create_or_update_connection(to_user, from_user, 0)
  end

  def self.connect_with_users_from_event(user, event)
    event.rsvps.attending_or_maybe_attending.all.each do |rsvp|
      c = create_or_update_connection(user, rsvp.user, EVENT_ATTENDANCE_STENGTH_INCREASE)

      #TODO - should the connection be this way? or the opposite so only ppl who didn't go end up with improper connections
      c = create_or_update_connection(rsvp.user, user, 0)
    end
  end

  def self.create_or_update_connection(user, to_user, strength_increase = 0)
    return nil if user.id == to_user.id

    c = user.connections.to_user(to_user).first
    c ||= user.connections.create({:to_user => to_user})

    c.strength += strength_increase #TODO - make this time sensitive

    c.save!
  end

  def self.set_all_ranks(user)
    Connection.connection.update("UPDATE connections co
          SET rank = ranked_tbl.newRank
          FROM (
            SELECT c.id, rank() OVER (PARTITION BY c.user_id ORDER BY strength DESC) newRank
            FROM connections c
            WHERE c.user_id = #{user.id}
          ) as ranked_tbl
          WHERE co.id = ranked_tbl.id")
  end

  protected

  def set_rank
    set_all_ranks(self.user)

    return;
    #find rank based on strength
#    insert_rank_obj = Connection.select("rank").where("connections.user_id = ? AND connections.strength < ?", self.user_id, self.strength).order("rank").first
#
#    if insert_rank_obj
#      old_rank = self.rank
#
#      #insert into list at object rank
#      self.rank = insert_rank_obj.rank
#
#      #increase the rank of all objects between this rank and old rank
#      if old_rank
#        Connection.update_all "rank = rank + 1",
#          ["connections.user_id = ? AND connections.rank >= ? AND connections.rank < ?", self.user_id, self.rank, old_rank]
#      else
#        Connection.update_all "rank = rank + 1",
#          ["connections.user_id = ? AND connections.rank >= ?", self.user_id, self.rank]
#      end
#    else
#      #insert into end of list
#      self.rank = Connection.where("connections.user_id = ?", self.user_id).count
#    end
  end
end
