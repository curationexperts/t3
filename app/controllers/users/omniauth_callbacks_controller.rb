module Users
  # Authentication callback controller for third-party authenticaion
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google
      user = User.from_omniauth(auth)

      if user.present?
        sign_in_and_redirect user, event: :authentication
      else
        session['devise.google_data'] = request.env['omniauth.auth'].except('extra')
        redirect_to new_user_session_path, alert: user.errors.full_messages.join("\n")
      end
    end

    protected

    def after_sign_in_path_for(resource_or_scope)
      stored_location_for(resource_or_scope) || root_path
    end

    private

    def auth
      @auth ||= request.env['omniauth.auth']
    end
  end
end
