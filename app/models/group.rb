class Group < ActiveRecord::Base

  has_many :user_groups
  has_many :users, :through => :user_groups

  validates :name, :presence => true

  def is_code_valid(group_code)
    user_group = UserGroup.where(:group_id => self, :join_code => group_code).limit(1).first
    return true if(user_group && user_group.user_id.blank?)
    return false
  end
end
