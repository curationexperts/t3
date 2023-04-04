require 'rails_helper'

RSpec.describe Field do
  let(:new_field) { described_class.new }
  let(:blueprint) {  Blueprint.create!(name: 'Field-Testing') }

  it 'must belong to a blueprint', :aggregate_failures do
    expect { new_field.save! }.to raise_exception ActiveRecord::RecordInvalid
    expect(new_field.errors.full_messages).to include 'Blueprint must exist'
  end

  it 'must have a name', :aggregate_failures do
    new_field.blueprint = blueprint
    expect { new_field.save! }.to raise_exception ActiveRecord::RecordInvalid
    expect(new_field.errors.full_messages).to include "Name can't be blank"
  end

  it 'name can only use valid characters', :aggregate_failures do
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

    it 'orders new fields at the end', :aggregate_failures do
      field1 = described_class.create!(blueprint: blueprint, name: 'field_1')
      field2 = described_class.create!(blueprint: blueprint, name: 'field_2')
      field3 = described_class.create!(blueprint: blueprint, name: 'field_3')
      expect(field3.order).to be > field2.order
      expect(field2.order).to be > field1.order
    end
  end
end
