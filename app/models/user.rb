class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  has_many :authentications
  has_many :rsvps

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name

  validates :first_name, :presence => true
  validates :last_name, :presence => true

  def apply_omniauth(omniauth)
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def name
    if first_name? || last_name?
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
