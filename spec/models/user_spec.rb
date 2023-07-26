require 'rails_helper'

RSpec.describe User do
  let(:user) { FactoryBot.create(:user) }
  let(:role) { FactoryBot.create(:role) }

  it 'can have roles', :aggregate_failures do
    user.roles << role
    expect(user.roles).to include role
    expect(role.users).to include user
  end

  it 'has no roles when initialized' do
    expect(user.roles).to be_empty
  end

  describe '.from_omniauth' do
    let(:auth) { FactoryBot.build(:google_auth_hash) }

    it 'creates a user with attributes from the auth data' do
      user = described_class.from_omniauth(auth)
      expect(user.as_json).to include(
        'email' => 'john@example.com',
        'provider' => 'google',
        'uid' => '100000000000000000000',
        'display_name' => 'John Smith',
        'guest' => false
      )
    end
  end
end
