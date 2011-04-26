class Authentication < ActiveRecord::Base

  serialize :auth_response, Hash

  belongs_to :user

  scope :facebook, where(:provider => "facebook")

end
