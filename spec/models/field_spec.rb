require 'rails_helper'

RSpec.describe Field, :aggregate_failures do
  let(:new_field) { described_class.new }
  let(:blueprint) {  Blueprint.create!(name: 'Field-Testing') }

  it 'must belong to a blueprint' do
    expect { new_field.save! }.to raise_exception ActiveRecord::RecordInvalid
    expect(new_field.errors.full_messages).to include 'Blueprint must exist'
  end

  it 'must have a name' do
    new_field.blueprint = blueprint
    expect { new_field.save! }.to raise_exception ActiveRecord::RecordInvalid
    expect(new_field.errors.full_messages).to include "Name can't be blank"
  end

  it 'name can only use valid characters' do
    new_field.blueprint = blueprint
    new_field.name = 'bad name!'
    expect(new_field.save).to be false
    expect(new_field.errors.full_messages)
      .to include 'Name can only contain letters, numbers, dashes, underscores, and periods'
  end

  it 'is optional (not required) by default' do
    expect(new_field.required).to be false
  end

  it 'is single valued (not multiple) by default' do
    expect(new_field.multiple).to be false
  end

  describe '#order' do
    it 'is undefined before inital save' do
      expect(new_field.order).to be_nil
    end

    it 'orders new fields at the end' do
      field1 = described_class.create!(blueprint: blueprint, name: 'field_1')
      field2 = described_class.create!(blueprint: blueprint, name: 'field_2')
      field3 = described_class.create!(blueprint: blueprint, name: 'field_3')
      expect(field3.order).to be > field2.order
      expect(field2.order).to be > field1.order
    end
  end

  describe '#dynamic_field_name' do
    let(:new_field) { described_class.new(blueprint: blueprint, name: 'attribute') }

    it 'includes the base name' do
      expect(new_field.dynamic_field_name).to match(/attribute/)
    end

    it 'includes a multiple flag (m)' do
      new_field.multiple = false
      expect(new_field.dynamic_field_name).to match(/[^m]$/)
      new_field.multiple = true
      expect(new_field.dynamic_field_name).to match(/m$/)
    end

    it 'includes a type flag', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
      new_field.data_type = 'text'
      expect(new_field.dynamic_field_name).to match(/_t/)
      new_field.data_type = 'string'
      expect(new_field.dynamic_field_name).to match(/_s/)
      new_field.data_type = 'integer'
      expect(new_field.dynamic_field_name).to match(/_i/)
      new_field.data_type = 'float'
      expect(new_field.dynamic_field_name).to match(/_f/)
      new_field.data_type = 'date'
      expect(new_field.dynamic_field_name).to match(/_dt/)
      new_field.data_type = 'boolean'
      expect(new_field.dynamic_field_name).to match(/_b/)
      new_field.data_type = nil
      expect(new_field.dynamic_field_name).to match(/_xx/)
    end
  end
end
