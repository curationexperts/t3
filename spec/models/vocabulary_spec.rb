require 'rails_helper'

RSpec.describe Vocabulary do
  let(:vocab) { FactoryBot.build(:vocabulary) }

  describe '#label' do
    it 'is required' do
      vocab.label = nil
      vocab.validate
      expect(vocab.errors.where(:label, :blank)).to be_present
    end

    it 'must be unique (case insensitive)' do
      vocab.label = 'My_TEST_Vocabulary'
      vocab.save!
      another = FactoryBot.build(:vocabulary, label: 'my_test_vocabulary')
      another.validate
      expect(another.errors.where(:label, :taken)).to be_present
    end
  end

  describe '#key' do
    it 'is required' do
      # Temporarily stub method that ensures key is set before validations
      allow(vocab).to receive(:set_key)

      vocab.key = nil
      vocab.validate
      expect(vocab.errors.where(:key, :blank)).to be_present
    end

    it 'gets set from the label when missing' do
      vocab.label = 'Kontrollü Terimler -- Sözlük!'
      vocab.key = ''
      vocab.save!
      expect(vocab.key).to eq 'kontrollu-terimler-sozluk'
    end

    it 'must be unique' do
      vocab.key = 'my-test-vocabulary'
      vocab.save!
      another = FactoryBot.build(:vocabulary, key: 'my-test-vocabulary')
      another.validate
      expect(another.errors.where(:key, :taken)).to be_present
    end

    describe 'patterns' do
      it 'can contain letters, numbers and dashes' do
        vocab.key = 'marc-9xx-extensions'
        expect(vocab).to be_valid
      end

      it 'can not include spaces' do
        vocab.key = 'spaces as separators'
        vocab.validate
        expect(vocab.errors.where(:key, :invalid)).to be_present
      end

      it 'can not include underscores' do
        vocab.key = 'underscores_as_separators'
        vocab.validate
        expect(vocab.errors.where(:key, :invalid)).to be_present
      end

      it 'can not include symbols' do
        vocab.key = 'key-[with]-sybols'
        vocab.validate
        expect(vocab.errors.where(:key, :invalid)).to be_present
      end

      it 'can not include leading dash' do
        vocab.key = '-leading-dash'
        vocab.validate
        expect(vocab.errors.where(:key, :invalid)).to be_present
      end

      it 'can not include trailing dash' do
        vocab.key = 'trailing-dash-'
        vocab.validate
        expect(vocab.errors.where(:key, :invalid)).to be_present
      end

      it 'can not include repeated dashes' do
        vocab.key = 'repeated--dashes'
        vocab.validate
        expect(vocab.errors.where(:key, :invalid)).to be_present
      end
    end
  end

  describe '#to_param' do
    it 'returns the key' do
      expect(vocab.to_param).to eq vocab.key
    end
  end

  describe '#note' do
    it 'is optional' do
      vocab.note = nil
      expect(vocab).to be_valid
    end
  end
end
