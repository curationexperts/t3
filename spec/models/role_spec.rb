require 'rails_helper'

RSpec.describe Role do
  it 'reqires a name', :aggregate_failures do
    role = described_class.new(name: nil)
    expect(role).not_to be_valid
    expect(role.errors.full_messages).to include "Name can't be blank"
  end

  it 'must have a unige name', :aggregate_failures do
    # Make an existing role with a specific name
    described_class.create(name: 'first')
    # Attempt to make a new role with the same name
    role = described_class.new(name: 'first')
    expect(role).not_to be_valid
    expect(role.errors.full_messages).to include 'Name has already been taken'
  end

  it 'can have users', :aggregate_failures do
    user = FactoryBot.create(:user)
    role = FactoryBot.create(:role)
    role.users << user
    expect(role.users).to include user
    expect(user.roles).to include role
  end

  it 'has no users when initialized' do
    role = FactoryBot.create(:role)
    expect(role.users).to be_empty
  end
end
