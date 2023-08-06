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

  describe '.system_roles' do
    it 'returns a list of persistent (system) roles' do
      expect(described_class.system_roles.map(&:class).uniq).to eq [described_class]
    end

    it 'includes the expected roles' do
      expect(described_class.system_roles.map(&:name))
        .to contain_exactly('Super Admin', 'User Manager', 'Brand Manager', 'System Manager')
    end
  end

  describe 'a system role' do
    let(:system_role) { described_class.system_roles.first }

    it 'raises an error on deltion' do
      expect { system_role.delete }.to raise_error(ActiveRecord::ReadOnlyRecord, /system Role/)
    end

    it 'cannot be destroyed' do
      expect { system_role.destroy }.to raise_error(ActiveRecord::ReadOnlyRecord, /marked as readonly/)
    end

    it 'returns readonly? true' do
      expect(system_role.readonly?).to be true
    end

    it 'returns system? true' do
      expect(system_role.system?).to be true
    end
  end

  describe 'a user created role' do
    let(:regular_role) { FactoryBot.create(:role) }

    it 'can be deleted', :aggregate_failures do
      expect { regular_role.delete }.not_to raise_exception
      expect(regular_role).to be_frozen
    end

    it 'is not a system role' do
      expect(regular_role.system?).to be false
    end
  end
end
