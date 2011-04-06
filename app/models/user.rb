class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  has_many :authentications
  has_many :rsvps
  has_many :activities

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name

#  validates :first_name, :presence => true
#  validates :last_name, :presence => true

  def apply_omniauth(omniauth)
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'], :auth_response => omniauth)
    if omniauth['extra'] && user_info = omniauth['extra']['user_hash']
      self.username = user_info['screen_name'] if !user_info['screen_name'].blank? && self.username.blank?
      if !user_info['name'].blank?
        split = user_info['name'].split
        if self.first_name.blank?
          self.first_name = split.size == 2 ? split.first : user_info['name']
        end
        if self.last_name.blank?
          self.last_name = split.last if split.size == 2
        end
      end
      self.email = user_info['email'] if !user_info['email'].blank? && self.email.blank?
    end
  end

  def name
    if username?
      username
    elsif first_name? || last_name?
      "#{first_name} #{last_name}"
    else
      "Sir/Madam" # for now, should have more conditions before this
    end
  end

  
  def password_required?
    # The '&& super' part of the code was in the Railscast but raises an error:
    # super: no superclass method `password_required?' for #<User:0x00000101aca448>
    # Not sure why, maybe Devise no longer has this method?
    (authentications.empty? || !password.blank?) # && super
  end

  
end
