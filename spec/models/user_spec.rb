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
end
