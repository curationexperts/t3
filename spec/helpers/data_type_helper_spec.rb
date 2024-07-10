require 'rails_helper'

RSpec.describe DataTypeHelper do
  describe '#data_type_optons' do
    let(:options) { helper.data_type_options }

    it 'includes basic data types' do
      expect(options['Core Types'].map(&:second)).to include('string', 'date', 'boolean')
    end

    it 'includes local vocabularies (alphabetized)' do
      FactoryBot.create(:vocabulary, label: 'Resource Types')
      FactoryBot.create(:vocabulary, label: 'Custom Terms')
      expect(options['Local Vocabularies'].map(&:first)).to eq(['Custom Terms', 'Resource Types'])
    end

    it 'includes vocabulary ID in the option value' do
      vocab = FactoryBot.create(:vocabulary, label: 'Custom Terms')
      expect(options['Local Vocabularies'].map(&:second)).to include("vocabulary|#{vocab.id}")
    end
  end
end
