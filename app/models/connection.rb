class Connection < ActiveRecord::Base

  make_searchable :fields => %w{users.first_name users.last_name users.email}, :include => [:to_user]

  belongs_to :user
  belongs_to :to_user, :class_name => "User"

  scope :to_user, lambda { |user| where(:to_user_id => user.id) }

  scope :most_relevant_first, order("connections.strength DESC, connections.updated_at DESC")

  default_value_for :strength, 1

  


end
