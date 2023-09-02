module Users
  # Authentication callback controller for third-party authenticaion
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google
      user = User.from_omniauth(auth, token)

      if user.persisted?
        sign_in_and_redirect user, event: :authentication
      else
        session['devise.google_data'] = request.env['omniauth.auth'].except('extra')
        redirect_to new_user_session_path, alert: user.errors.full_messages.join("\n")
      end
    end

    private

    def auth
      request.env['omniauth.auth']
    end

    def token
      request.env.dig('omniauth.params', 'invitation_token')
    end
  end
end
