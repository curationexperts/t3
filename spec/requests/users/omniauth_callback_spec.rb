require 'rails_helper'

RSpec.describe 'Users::OmniauthCallbacksController' do
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google] = FactoryBot.build(:google_auth_hash)
  end

  after do
    OmniAuth.config.test_mode = false
  end

  describe '#google' do
    it 'redirects to the root on successful authentication' do
      post user_google_omniauth_authorize_path # No params required in test mode
      # see https://github.com/omniauth/omniauth/wiki/Integration-Testing#omniauthconfigtest_mode
      follow_redirect!
      expect(response).to redirect_to(root_path)
    end

    it 'redirects to signin on failed authentication', :aggregate_failures do
      # simulate failed login
      # see: https://github.com/omniauth/omniauth/wiki/Integration-Testing#mocking-failure
      OmniAuth.config.mock_auth[:google] = :invalid_credentials

      post user_google_omniauth_authorize_path # No params required in test mode
      follow_redirect!
      expect(response).to redirect_to(new_user_session_path)
      expect(flash.alert).to include 'Invalid credentials'
    end
  end
end
