require 'rails_helper'

RSpec.describe User do
  let(:user) { FactoryBot.create(:user) }

  it 'defaults provider to "local"' do
    expect(described_class.new.provider).to eq 'local'
  end

  it 'does not change passed provider' do
    expect(described_class.new(provider: 'imported').provider).to eq 'imported'
  end

  describe '#deactivate' do
    it 'marks the user as deactivated' do
      user.deactivate
      expect(user.deactivated_at?).to be true
    end

    it 'disables authentication', :aggregate_failures do
      expect(user.active_for_authentication?).to be true
      user.deactivate
      expect(user.active_for_authentication?).to be false
    end
  end

  describe '#local?' do
    let(:local_user) { FactoryBot.create(:user, provider: 'local') }
    let(:remote_user) { FactoryBot.create(:user, provider: 'google') }

    it 'is true for database (local) accounts' do
      expect(local_user.local?).to be true
    end

    it 'is false for non-local (omniauth) accounts' do
      expect(remote_user.local?).to be false
    end
  end

  describe '#current_sign_in_at' do
    it 'is nil for new users' do
      expect(described_class.new.current_sign_in_at).to be_nil
    end

    it 'can be set' do
      expect(user).to respond_to(:current_sign_in_at=)
    end
  end

  describe '#password_reset' do
    let(:local_user) { FactoryBot.create(:user, provider: 'local') }

    context 'with a valid local user' do
      it 'returns true' do
        expect(local_user.password_reset).to be true
      end

      it 'sends an e-mail' do
        local_user.password_reset
        mail = ActionMailer::Base.deliveries.last
        expect(mail.subject).to eq I18n.t('devise.mailer.reset_password_instructions.subject')
      end
    end

    context 'with a remote (OminAuth) user' do
      let(:remote_user) { FactoryBot.create(:user, provider: 'google') }

      it 'returns false' do
        expect(remote_user.password_reset).to be false
      end

      it 'adds an error to the user' do
        remote_user.password_reset
        expect(remote_user.errors.full_messages).to include 'User must change their password via Google.'
      end
    end
  end

  describe '#roles' do
    let(:role) { FactoryBot.create(:role) }

    it 'returns an empty array when initialized' do
      expect(described_class.new.roles).to be_empty
    end

    it 'accepts Role objects', :aggregate_failures do
      user.roles << role
      expect(user.roles).to include role
      expect(role.users).to include user
    end
  end

  describe '#role_name?' do
    let(:role) { FactoryBot.create(:role) }

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
    let(:token) { Devise.friendly_token(10) }
    let(:user) { FactoryBot.build(:user, email: 'john@example.com', uid: nil, display_name: nil, provider: 'local') }
    let(:auth) { FactoryBot.build(:google_auth_hash) }

    it 'finds and updates an invited user', :aggregate_failures do
      allow(described_class).to receive(:find_by_invitation_token).with(token, false).and_return(user)
      omniauth_user = described_class.from_omniauth(auth, token)
      expect(omniauth_user.as_json).to include(
        'email' => 'john@example.com',
        'provider' => 'google',
        'uid' => '100000000000000000000',
        'display_name' => 'John Smith',
        'guest' => false
      )
    end

    it 'returns an existing user' do
      user.uid = '200000000000000000000'
      allow(described_class).to receive(:find_by).and_return(user)
      omniauth_user = described_class.from_omniauth(auth, nil)
      expect(omniauth_user.uid).to eq '200000000000000000000'
    end

    it 'returns an error for unauthorized accounts' do
      omniauth_user = described_class.from_omniauth(auth, nil)
      expect(omniauth_user.errors.where(:base, :unauthorized_account)).to be_present
    end
  end

  describe 'with scopes' do
    let(:guest) { FactoryBot.create(:guest) }

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
