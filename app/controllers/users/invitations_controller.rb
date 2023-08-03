module Users
  # Subclass with restrictions on which users can invite others
  class InvitationsController < Devise::InvitationsController
    def authenticate_inviter!
      return unless cannot? :create, User

      render file: Rails.public_path.join('422.html'), status: :unprocessable_entity
    end

    def current_inviter
      current_user
    end

    def after_invite_path_for(_inviter, _invitee)
      users_path
    end
  end
end
