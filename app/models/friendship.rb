class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => "User"

  scope :by_friend, lambda {|user| where(:friend_id => user.id) }
  
end
