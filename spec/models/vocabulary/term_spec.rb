require 'rails_helper'

RSpec.describe Vocabulary::Term do
  let(:vocab) { FactoryBot.build(:vocabulary) }
  let(:term)  { FactoryBot.build(:vocabulary_term, vocabulary: vocab) }

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
      another_term = FactoryBot.build(:vocabulary_term, vocabulary: term.vocabulary, label: term.label)
      another_term.validate
      expect(another_term.errors.where(:label, :taken)).to be_present
    end

    it 'may be repeated in a different vocabulary' do
      term.save!
      different_vocab = FactoryBot.build(:vocabulary)
      different_term = FactoryBot.build(:vocabulary_term, vocabulary: different_vocab, label: term.label)
      different_term.validate
      expect(different_term.errors.where(:label, :taken)).not_to be_present
    end
  end

  describe '#slug' do
    it 'is required' do
      allow(term).to receive(:set_slug)
      term.slug = nil
      term.validate
      expect(term.errors.where(:slug, :blank)).to be_present
    end

    it 'is set from the label when blank' do
      term.label = 'First Term in Vocabulary'
      term.slug = nil
      term.validate
      expect(term.slug).to eq 'first-term-in-vocabulary'
    end

    it 'may contain letters, numbers, dashes, and underscores' do
      term.slug = 'A_valid_but-ugly-1234-SLUG'
      term.validate
      expect(term.errors.where(:slug, :invalid)).not_to be_present
    end

    it 'may not contain special characters' do
      term.slug = 'Invalid (Slug) with spaces & special characters'
      term.validate
      expect(term.errors.where(:slug, :invalid)).to be_present
    end
  end
end