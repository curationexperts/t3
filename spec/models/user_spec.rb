require 'rails_helper'

RSpec.describe User do
  let(:user) { FactoryBot.create(:user) }
  let(:guest) { FactoryBot.create(:guest) }
  let(:role) { FactoryBot.create(:role) }

  it 'defaults provider to "local"' do
    expect(described_class.new.provider).to eq 'local'
  end

  it 'does not change passed provider' do
    expect(described_class.new(provider: 'imported').provider).to eq 'imported'
  end

  describe '#roles' do
    it 'returns an empty array when initialized' do
      expect(user.roles).to be_empty
    end

    it 'accepts Role objects', :aggregate_failures do
      user.roles << role
      expect(user.roles).to include role
      expect(role.users).to include user
    end
  end

  describe '#role_name?' do
    it 'is true for users with the named role' do
      user.roles << role
      expect(user.role_name?(role.name)).to be true
    end

    it 'is false for users without the named role' do
      expect(user.role_name?(role.name)).to be false
    end

    it 'is false for non-existent role names' do
      expect(user.role_name?('Some made up name')).to be false
    end
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

  describe 'with scopes' do
    example '#registered', :aggregate_failures do
      expect(described_class.registered).to include user
      expect(described_class.registered).not_to include guest
    end

    example '#guest', :aggregate_failures do
      expect(described_class.guest).to include guest
      expect(described_class.guest).not_to include user
    end
  end
end
