require 'rails_helper'

RSpec.describe Ability do
  let(:user) { FactoryBot.build(:user) }
  let(:authz) { described_class.new(user) }

  before do
    allow(user).to receive(:role_name?).and_return(false)
    allow(user).to receive(:role_name?).with(role_name).and_return(true)
  end

  describe 'with role' do
    describe 'not set' do
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
        expect(authz.can?(:read, SolrService)).to be false
        expect(authz.can?(:read, Blueprint)).to be false
        expect(authz.can?(:read, Field)).to be false
        expect(authz.can?(:read, Ingest)).to be false
        expect(authz.can?(:read, Item)).to be false
        expect(authz.can?(:read, Collection)).to be false
        expect(authz.can?(:read, Config)).to be false
        expect(authz.can?(:read, Vocabulary)).to be false
      end
    end

    describe 'Super Admin' do
      let(:role_name) { 'Super Admin' }

      it 'has full privleges' do
        expect(authz.can?(:manage, :all)).to be true
      end
    end

    describe 'User Manager' do
      let(:role_name) { 'User Manager' }

      it 'can manage Users' do
        expect(authz.can?(:manage, User)).to be true
      end

      it 'can manage Roles' do
        expect(authz.can?(:manage, Role)).to be true
      end

      it 'can read dashboard' do
        expect(authz.can?(:read, :dashboard)).to be true
      end

      it 'can read Status' do
        expect(authz.can?(:read, Status)).to be true
      end

      it 'cannot manage Themes' do
        expect(authz.can?(:read, Theme)).to be false
      end

      it 'cannot manage Items' do
        expect(authz.can?(:read, Item)).to be false
      end
    end

    describe 'Brand Manager' do
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

      it 'cannot manage Vocabularies' do
        expect(authz.can?(:read, Vocabulary)).to be false
      end
    end

    describe 'System Manager' do
      let(:role_name) { 'System Manager' }

      it 'can manage Blueprints' do
        expect(authz.can?(:manage, Blueprint)).to be true
      end

      it 'can manage Fields' do
        expect(authz.can?(:manage, Field)).to be true
      end

      it 'can manage Config' do
        expect(authz.can?(:manage, Config)).to be true
      end

      it 'can manage Ingests' do
        expect(authz.can?(:manage, Ingest)).to be true
      end

      it 'can manage Items' do
        expect(authz.can?(:manage, Item)).to be true
      end

      it 'can manage Collections' do
        expect(authz.can?(:manage, Collection)).to be true
      end

      it 'can manage Vocabularies' do
        expect(authz.can?(:manage, Vocabulary)).to be true
      end

      it 'can read dashboard' do
        expect(authz.can?(:read, :dashboard)).to be true
      end

      it 'can read Status' do
        expect(authz.can?(:read, Status)).to be true
      end

      it 'cannot manage Users' do
        expect(authz.can?(:read, User)).to be false
      end
    end

    describe 'multiple combined' do
      let(:role_name) { '' }

      before do
        allow(user).to receive(:role_name?).with('User Manager').and_return(true)
        allow(user).to receive(:role_name?).with('System Manager').and_return(true)
      end

      it 'can manage User related features', :aggregate_failures do
        expect(authz.can?(:manage, User)).to be true
        expect(authz.can?(:manage, Role)).to be true
      end

      it 'can manage Content related features', :aggregate_failures do
        expect(authz.can?(:manage, Item)).to be true
        expect(authz.can?(:manage, Field)).to be true
        expect(authz.can?(:manage, Ingest)).to be true
        expect(authz.can?(:manage, Vocabulary)).to be true
      end

      it 'can not manage Brand related features' do
        expect(authz.can?(:manage, Theme)).to be false
      end

      it 'can read dashboard status' do
        expect(authz.can?(:read, :dashboard)).to be true
      end
    end
  end
end
