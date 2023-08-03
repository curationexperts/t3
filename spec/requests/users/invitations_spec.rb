require 'rails_helper'

RSpec.describe 'Users::InvitationsController' do
  let(:super_admin)  { FactoryBot.create(:super_admin) }
  let(:regular_user) { FactoryBot.create(:user) }

  before { login_as super_admin }

  describe 'POST users/invitations' do
    it 'creates a new user' do
      expect do
        post user_invitation_path, params: { user: { email: 'invitee@example.org' } }
      end.to change(User, :count).by(1)
    end

    it 'sends an invitation e-mail', :aggregate_failures do
      post user_invitation_path, params: { user: { email: 'invitee@example.org' } }
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq(['invitee@example.org'])
      expect(mail.subject).to eq('Invitation instructions')
    end

    it 'redirects to admin/users' do
      post user_invitation_path, params: { user: { email: 'invitee@example.org' } }
      expect(response).to redirect_to users_path
    end
  end

  it 'restricts unauthorized users' do
    login_as regular_user # who does not have user management abilities
    post user_invitation_path, params: { user: { email: 'invitee@example.org' } }
    expect(response).to be_unprocessable
  end
end
