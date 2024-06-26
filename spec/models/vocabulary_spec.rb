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
  end

  describe '#slug' do
    it 'is required' do
      # Temporarily stub method that ensures slug is set before validations
      allow(vocab).to receive(:set_slug)

      vocab.slug = nil
      vocab.validate
      expect(vocab.errors.where(:slug, :blank)).to be_present
    end

    it 'gets set from the name when missing' do
      vocab.name = 'Kontrollü Terimler -- Sözlük!'
      vocab.slug = nil
      vocab.save!
      expect(vocab.slug).to eq 'kontrollu-terimler-sozluk'
    end

    it 'must be unique' do
      vocab.slug = 'my-test-vocabulary'
      vocab.save!
      another = FactoryBot.build(:vocabulary, slug: 'my-test-vocabulary')
      another.validate
      expect(another.errors.where(:slug, :taken)).to be_present
    end

    it 'can only contain letters or dashes' do
      vocab.slug = '5 invalid^chars__OH_No!'
      vocab.validate
      expect(vocab.errors.where(:slug, :invalid)).to be_present
    end
  end

  describe '#description' do
    it 'is optional' do
      vocab.description = nil
      expect(vocab).to be_valid
    end
  end
end
