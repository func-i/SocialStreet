class Authentication < ActiveRecord::Base

  serialize :auth_response, Hash

  belongs_to :user

  after_create :set_fb_uid
  after_create :load_facebook_friends

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

  def load_facebook_friends
    Resque.enqueue(Jobs::Facebook::CreateConnectionsFromFacebook, user.id) if facebook?
  end


end
