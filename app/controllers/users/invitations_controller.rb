module Users
  # Subclass of devise_invitable invitations controller that
  # - Restricts which users can invite others
  # - Allows additional parameters when creating invited users
  # - Redirects to the user dashboard after issuing an invite
  class InvitationsController < Devise::InvitationsController
    before_action :configure_permitted_parameters

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

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:invite, keys: [:display_name, { role_ids: [] }])
    end
  end
end
