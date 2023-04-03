require 'rails_helper'

RSpec.describe Blueprint do
  let(:new_blueprint) { described_class.new }

  describe '#name', :aggregate_failures do
    it 'is required' do
      expect { new_blueprint.save! }.to raise_exception ActiveRecord::RecordInvalid
      expect(new_blueprint.errors.full_messages).to include "Name can't be blank"
    end

    describe 'validation' do
      it 'can use [a-zA-Z0-9_-.]' do
        new_blueprint.name = 'I_am-1.valid_nam3'
        expect { new_blueprint.save! }.not_to raise_exception
      end

      it 'raises an validation error for other speical characers' do
        new_blueprint.name = 'bad name!'
        expect { new_blueprint.save! }.to raise_exception ActiveRecord::RecordInvalid
      end

      it 'provides a helpful error message' do
        new_blueprint.name = 'bad name!'
        expect(new_blueprint.save).to be false
        expect(new_blueprint.errors.full_messages)
          .to include 'Name can only contain letters, numbers, dashes, underscores, and periods'
      end
    end
  end

  describe '#fields' do
    example 'are blank on new blueprints' do
      expect(new_blueprint.fields).to be_empty
    end
  end
end
