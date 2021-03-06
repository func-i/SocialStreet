class UserGroup < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  after_save :default_applied

  scope :applied, where(:applied => true)
  scope :not_applied, where(:applied => false)

  scope :search, lambda {|keyword|
    includes(:user).
      where("(user_groups.external_name ~* ? OR user_groups.external_email ~* ? OR user_groups.join_code ~* ? OR users.first_name ~* ? OR users.last_name ~* ?)", keyword, keyword, keyword, keyword, keyword)
  }

  def get_name
    self.external_name || user.try(:name)
  end

  def get_email
    self.external_email || user.try(:email)
  end

  def to_s
    get_name() || self.external_email || self.join_code
  end

  protected

  def default_applied
    update_attributes :applied => false if applied.nil?
  end
end
