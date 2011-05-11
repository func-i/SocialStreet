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

  default_value_for :strength, 1

  default_value_for :facebook_friend, false

  def self.connect_with_users_in_action_thread(user, an_action)
      threaded_actions = Action.threaded_with(an_action).all

      threaded_actions.each do |action|
        shared_comment_thread(user, action.user)
      end
  end

  def self.shared_comment_thread(commentee_user, commented_user)
    return false if commentee_user.id == commented_user.id

    c = commentee_user.connections.to_user(commented_user).first
    c ||= commentee_user.connections.create({:to_user => commented_user})

    #TODO - should this work both ways? or should a connection only be created when the user initiates
    #c = commented_user.connections.to_user(commentee_user).first
    #c ||= commented_user.connections.create({:to_user => commentee_user})

  end
end
