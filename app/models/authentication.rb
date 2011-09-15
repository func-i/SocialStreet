class Authentication < ActiveRecord::Base

  serialize :auth_response, Hash

  belongs_to :user

  after_create :set_fb_uid

  scope :facebook, where(:provider => "facebook")

  def facebook?
    provider == "facebook"
  end

  def fb_auth_token
    auth_response["credentials"]["token"] if facebook?
  end

  protected

  def set_fb_uid
    if facebook? && user && user.fb_uid.blank?
      user.update_attributes :fb_uid => self.uid
    end
  end

end
