require 'rails_helper'

RSpec.describe 'Users::OmniauthCallbacksController' do
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google] = FactoryBot.build(:google_auth_hash)
  end

  describe '#google' do
    it 'redirects to the root on successful authentication', :aggregate_failures do
      post user_google_omniauth_authorize_path # No params required in test mode
      expect(response).to redirect_to(user_google_omniauth_callback_path)
      follow_redirect!
      expect(response).to redirect_to(root_path)
    end

    it 'redirects to signin on failed authentication', :aggregate_failures do
      # simulate failed login
      allow(User).to receive(:from_omniauth).and_return(nil)
      post user_google_omniauth_authorize_path # No params required in test mode
      expect(response).to redirect_to(user_google_omniauth_callback_path)
      follow_redirect!
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
