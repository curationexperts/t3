require 'rails_helper'

RSpec.describe Blueprint, :aggregate_failures do
  let(:blueprint) { described_class.new }

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
    it 'defaults to an empty list' do
      expect(described_class.new.fields).to eq []
    end

    it 'validates when empty' do
      blueprint.name = FactoryBot.attributes_for(:blueprint)[:name]
      blueprint.fields = []
      expect(blueprint).to be_valid
    end

    it 'may contain FieldConfig objects' do
      blueprint.name = FactoryBot.attributes_for(:blueprint)[:name]
      blueprint.fields << FactoryBot.build(:field_config)
      expect(blueprint).to be_valid
    end

    it 'can be persisted' do
      fields = [FactoryBot.build(:field_config), FactoryBot.build(:field_config), FactoryBot.build(:field_config)]
      blueprint = FactoryBot.create(:blueprint, fields: fields)
      persisted = described_class.find(blueprint.id)
      expect(persisted.fields.count).to eq 3
      expect(persisted.fields.map(&:class).uniq).to eq [FieldConfig]
    end
  end
end
