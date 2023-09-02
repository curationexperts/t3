# User object authentication and authorization
class User < ApplicationRecord
  has_and_belongs_to_many :roles

  scope :registered, -> { where(guest: false) }
  scope :guest, -> { where(guest: true) }

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :trackable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google]

  # Configuration added by Blacklight; Blacklight::User uses a method key on your
  # user class to get a user-displayable login/identifier for
  # the account.
  self.string_display_key ||= :email

  def initialize(attributes = nil)
    super
    self.provider ||= 'local'
  end

  # Deactivate the user and clear any outstanding invitations
  # Deactivation should be persisted even if the user is invalid,
  # so we user update_attribute to skip validations before save
  def deactivate
    self.invitation_token = nil
    update_attribute(:deactivated_at, Time.now.utc) # rubocop:disable Rails/SkipsModelValidations
  end

  # do not permit deactivated users to login
  def active_for_authentication?
    super && !deactivated_at
  end

  def local?
    provider == 'local'
  end

  def role_name?(name)
    role_names.include?(name)
  end

  def role_names
    @role_names ||= roles.map(&:name)
  end

  def password_reset
    if local?
      send_reset_password_instructions
    else # Can't reset OmniAuth account passwords
      errors.add(:base, :remote_password_reset, message: "User must change their password via #{provider.titlecase}.")
    end
    errors.empty?
  end

  def self.from_omniauth(auth, token = nil)
    new_user_from_token(token, auth) || existing_user_from_auth(auth) || invalid_user
  end

  def self.new_user_from_token(token, auth)
    return unless token

    user = User.find_by_invitation_token(token, false)
    user.update(email: auth.info.email,
                display_name: auth.info.name,
                provider: auth.provider,
                uid: auth.uid)
    user
  end
  private_class_method :new_user_from_token

  def self.existing_user_from_auth(auth)
    find_by(provider: auth.provider, uid: auth.uid)
  end
  private_class_method :existing_user_from_auth

  def self.invalid_user
    User.new.tap { |u| u.errors.add(:base, :unauthorized_account) }
  end
  private_class_method :invalid_user
end
