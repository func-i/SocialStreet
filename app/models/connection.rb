class Connection < ActiveRecord::Base
  belongs_to :user
  belongs_to :to_user, :class_name => "User"

  scope :to_user, lambda { |user| where(:to_user_id => user.id) }
  scope :to_user_id, lambda { |user_id| where(:to_user_id => user_id) }
end
