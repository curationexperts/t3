require 'rails_helper'

RSpec.describe Blueprint, :aggregate_failures do
  let(:blueprint) { described_class.new }

  it 'has a vaild factory' do
    expect(FactoryBot.build(:blueprint)).to be_valid
  end

  it 'initializes a default instance' do
    expect(described_class.where(name: 'Default')).to exist
  end

  describe 'name' do
    it 'cannot be blank' do
      expect(blueprint).not_to be_valid
      expect(blueprint.errors.where(:name, :blank)).to be_present
      expect(blueprint.errors.where(:name, :invalid)).not_to be_present
    end

    it 'must be unique' do
      existing = FactoryBot.create(:blueprint)
      blueprint.name = existing.name
      expect(blueprint).not_to be_valid
      expect(blueprint.errors.where(:name, :taken)).to be_present
    end

    it 'can not contain special characters' do
      blueprint.name = 'This & That'
      expect(blueprint).not_to be_valid
      expect(blueprint.errors.where(:name, :invalid)).to be_present
    end
  end

  describe 'fields' do
    it 'defaults to all active fields' do
      FactoryBot.create_list(:field, 2)
      expect(blueprint.fields).to match_array Field.active
    end
  end
end
