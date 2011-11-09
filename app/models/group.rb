class Group < ActiveRecord::Base

  has_many :user_groups
  has_many :users, :through => :user_groups

  validates :name, :presence => true

  scope :is_member, lambda { |user| where(:user_id => user) }

  def is_member?(user)
    return false unless user

    user.groups.each do |group|
      return true if group == self
    end
    return false
  end

  def can_edit?(user)
    return false unless user

    return true if 0 < UserGroup.where(:group_id => self, :user_id => user, :administrator => true).limit(1).count
    return false
  end

  def is_code_valid(group_code)
    user_group = UserGroup.where(:group_id => self, :join_code => group_code).limit(1).first
    return true if(user_group && user_group.user_id.blank?)
    return false
  end

  def is_public()
    return join_code_description.blank?
  end
end
