require 'rails_helper'

RSpec.describe Term do
  let(:term) { FactoryBot.build(:term) }

  it 'must belong to a vocabulary' do
    term.vocabulary = nil
    term.validate
    expect(term.errors.where(:vocabulary, :blank)).to be_present
  end

  describe '#label' do
    it 'is required' do
      term.label = nil
      term.validate
      expect(term.errors.where(:label, :blank)).to be_present
    end

    it 'must be unique (within vocabulary)' do
      term.save!
      another_term = FactoryBot.build(:term, vocabulary: term.vocabulary, label: term.label)
      another_term.validate
      expect(another_term.errors.where(:label, :taken)).to be_present
    end

    it 'may be repeated in a different vocabulary' do
      term.save!
      different_vocab = FactoryBot.build(:vocabulary)
      different_term = FactoryBot.build(:term, vocabulary: different_vocab, label: term.label)
      different_term.validate
      expect(different_term.errors.where(:label, :taken)).not_to be_present
    end
  end

  describe '#key' do
    it 'is required' do
      allow(term).to receive(:set_key)
      term.key = nil
      term.validate
      expect(term.errors.where(:key, :blank)).to be_present
    end

    it 'is set from the label when blank' do
      term.label = 'First Term in Vocabulary'
      term.key = ''
      term.validate
      expect(term.key).to eq 'first-term-in-vocabulary'
    end

    it 'may contain letters, numbers, dashes, and underscores' do
      term.key = 'A_valid_but-ugly-1234-KEY'
      term.validate
      expect(term.errors.where(:key, :invalid)).not_to be_present
    end

    it 'may not contain special characters' do
      term.key = 'Invalid (key) with spaces & special characters'
      term.validate
      expect(term.errors.where(:key, :invalid)).to be_present
    end
  end

  describe '#to_param' do
    it 'returns the key' do
      expect(term.to_param).to eq term.key
    end
  end
end
