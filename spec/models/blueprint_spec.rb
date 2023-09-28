require 'rails_helper'

RSpec.describe Blueprint, :aggregate_failures do
  describe 'name' do
    let(:blueprint) { described_class.new }

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
end
