# User object authentication and authorization
class User < ApplicationRecord
  has_and_belongs_to_many :roles

  scope :registered, -> { where(guest: false) }
  scope :guest, -> { where(guest: true) }

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google]

  # Configuration added by Blacklight; Blacklight::User uses a method key on your
  # user class to get a user-displayable login/identifier for
  # the account.
  self.string_display_key ||= :email

  def self.from_omniauth(auth)
    provider = auth.provider
    uid = auth.uid
    email = auth.info.email
    display_name = auth.info.name

    # Only permit users from curationexperts.com
    # return nil unless email =~ /@curationexperts.com\z/

    create_with(email: email, password: dummy_password, display_name: display_name)
      .find_or_create_by!(provider: provider, uid: uid)
  end

  def self.dummy_password
    Devise.friendly_token(20)
  end

  def role_name?(name)
    role_names.include?(name)
  end

  def role_names
    @role_names ||= roles.map(&:name)
  end
end
