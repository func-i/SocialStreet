class UserGroup < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  after_create :default_applied

  scope :applied, where(:applied => true)
  scope :not_applied, where(:applied => false)

  scope :search, lambda {|keyword|
    includes(:user).
      where("user_groups.external_name ~* ? OR user_groups.external_email ~* ? OR user_groups.join_code ~* ? OR users.name ~* ?", keyword, keyword, keyword, keyword)
  }

  def to_s
    (user && user.name) || self.external_name || self.external_email || self.join_code
  end

  protected

  def default_applied
    update_attributes :applied => false unless applied
  end
end
