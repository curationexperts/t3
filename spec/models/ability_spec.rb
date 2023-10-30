require 'rails_helper'

RSpec.describe Ability do
  let(:user) { FactoryBot.build(:user) }
  let(:authz) { described_class.new(user) }

  before do
    allow(user).to receive(:role_name?).and_return(false)
    allow(user).to receive(:role_name?).with(role_name).and_return(true)
  end

  describe 'from role' do
    describe 'with no roles' do
      let(:role_name) { '' }

      it 'allows anyone to read the current theme' do
        expect(authz.can?(:read, Theme.current)).to be true
      end

      it 'restricts dashboard' do
        expect(authz.can?(:read, :dashboard)).to be false
      end

      it 'restricts access to admin models', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        # this should be a relatively exhaustive list of
        # models and keywords that should enforce some for of authroization restrictions
        expect(authz.can?(:read, User)).to be false
        expect(authz.can?(:read, Role)).to be false
        expect(authz.can?(:read, Theme)).to be false
        expect(authz.can?(:read, Config)).to be false
        expect(authz.can?(:read, Blueprint)).to be false
        expect(authz.can?(:read, Ingest)).to be false
      end
    end

    describe 'as Super Admin' do
      let(:role_name) { 'Super Admin' }

      it 'has full privleges' do
        expect(authz.can?(:manage, :all)).to be true
      end
    end

    describe 'as User Manager' do
      let(:role_name) { 'User Manager' }

      it 'can manage Users' do
        expect(authz.can?(:manage, User)).to be true
      end

      it 'can manage Roles' do
        expect(authz.can?(:manage, Role)).to be true
      end

      it 'can read dashboard status' do
        expect(authz.can?(:read, :dashboard)).to be true
      end

      it 'cannot manage Themes' do
        expect(authz.can?(:read, Theme)).to be false
      end
    end

    describe 'as Brand Manager' do
      let(:role_name) { 'Brand Manager' }

      it 'can manage Theme' do
        expect(authz.can?(:manage, Theme)).to be true
      end

      it 'can read dashboard status' do
        expect(authz.can?(:read, :dashboard)).to be true
      end

      it 'cannot manage Roles' do
        expect(authz.can?(:read, Role)).to be false
      end
    end

    describe 'as System Manager' do
      let(:role_name) { 'System Manager' }

      it 'can manage Connfigs' do
        expect(authz.can?(:manage, Config)).to be true
      end

      it 'can manage Blueprints' do
        expect(authz.can?(:manage, Blueprint)).to be true
      end

      it 'can manage Ingests' do
        expect(authz.can?(:manage, Ingest)).to be true
      end

      it 'can read dashboard status' do
        expect(authz.can?(:read, :dashboard)).to be true
      end

      it 'cannot manage Users' do
        expect(authz.can?(:read, User)).to be false
      end
    end

    describe 'with multiple roles' do
      let(:role_name) { '' }

      before do
        allow(user).to receive(:role_name?).with('User Manager').and_return(true)
        allow(user).to receive(:role_name?).with('System Manager').and_return(true)
      end

      it 'can manage multiple features', :aggregate_failures do
        expect(authz.can?(:manage, User)).to be true
        expect(authz.can?(:manage, Config)).to be true
        expect(authz.can?(:manage, Theme)).to be false
        expect(authz.can?(:manage, Blueprint)).to be true
        expect(authz.can?(:manage, Ingest)).to be true
      end

      it 'can read dashboard status' do
        expect(authz.can?(:read, :dashboard)).to be true
      end
    end
  end
end
