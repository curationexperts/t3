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
      vocab.slug = ''
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

    describe 'patterns' do
      it 'can contain letters, numbers and dashes' do
        vocab.slug = 'marc-9xx-extensions'
        expect(vocab).to be_valid
      end

      it 'can not include spaces' do
        vocab.slug = 'spaces as separators'
        vocab.validate
        expect(vocab.errors.where(:slug, :invalid)).to be_present
      end

      it 'can not include underscores' do
        vocab.slug = 'underscores_as_separators'
        vocab.validate
        expect(vocab.errors.where(:slug, :invalid)).to be_present
      end

      it 'can not include symbols' do
        vocab.slug = 'slug-[with]-sybols'
        vocab.validate
        expect(vocab.errors.where(:slug, :invalid)).to be_present
      end

      it 'can not include leading dash' do
        vocab.slug = '-leading-dash'
        vocab.validate
        expect(vocab.errors.where(:slug, :invalid)).to be_present
      end

      it 'can not include trailing dash' do
        vocab.slug = 'trailing-dash-'
        vocab.validate
        expect(vocab.errors.where(:slug, :invalid)).to be_present
      end

      it 'can not include repeated dashes' do
        vocab.slug = 'repeated--dashes'
        vocab.validate
        expect(vocab.errors.where(:slug, :invalid)).to be_present
      end
    end
  end

  describe '#to_param' do
    it 'returns the slug' do
      expect(vocab.to_param).to eq vocab.slug
    end
  end

  describe '#description' do
    it 'is optional' do
      vocab.description = nil
      expect(vocab).to be_valid
    end
  end
end
