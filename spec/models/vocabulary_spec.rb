require 'rails_helper'

RSpec.describe Vocabulary do
  let(:vocab) { FactoryBot.build(:vocabulary) }

  describe '#name' do
    it 'is required' do
      vocab.name = nil
      vocab.validate
      expect(vocab.errors.where(:name, :blank)).to be_present
    end

    it 'must be unique (case insensitive)' do
      vocab.name = 'My_TEST_Vocabulary'
      vocab.save!
      another = FactoryBot.build(:vocabulary, name: 'my_test_vocabulary')
      another.validate
      expect(another.errors.where(:name, :taken)).to be_present
    end

    it 'can only contain alphanumerics, dashes, or underscores' do
      vocab.name = 'invalid^chars'
      vocab.validate
      expect(vocab.errors.where(:name, :invalid)).to be_present
    end
  end

  describe '#description' do
    it 'is optional' do
      vocab.description = nil
      expect(vocab).to be_valid
    end
  end
end
