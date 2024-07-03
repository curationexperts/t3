require 'rails_helper'

RSpec.describe Config do
  let(:config) { described_class.current }

  it 'is a singleton', :aggregate_failures do
    expect(described_class.instance).to be_present
    expect { described_class.new }.to raise_exception(NoMethodError)
  end

  describe '.current' do
    it 'is an alias for .instance' do
      expect(described_class.current.object_id).to eq described_class.instance.object_id
    end
  end

  describe '#settings' do
    it 'returns basic context information' do
      expect(config.settings[:context])
        .to include(description: 'T3 Configuration export',
                    timestamp: /\d{4}-\d{2}-\d{2}/)
    end

    it 'returns the current fields' do
      field = FactoryBot.create(:field)
      expect(config.settings)
        .to include(fields: a_collection_including(field))
    end

    context 'with multiple vocabularies' do
      let(:short_list) { FactoryBot.create(:vocabulary, name: 'Shorter List') }
      let(:long_list) { FactoryBot.create(:vocabulary, name: 'Longer List') }

      before do
        FactoryBot.create_list(:term, 1, vocabulary: short_list)
        FactoryBot.create_list(:term, 3, vocabulary: long_list)
      end

      it 'returns the current vocabularies & terms' do
        expect(config.settings[:vocabularies])
          .to(include(hash_including('slug' => 'longer-list', 'terms' => satisfying { |a| a.count == 3 }),
                      hash_including('slug' => 'shorter-list', 'terms' => satisfying { |a| a.count == 1 })))
      end
    end
  end

  describe '#update from a file' do
    it 'creates new vocabularies' do
      cfg_import_file = fixture_file_upload('config/empty_vocabulary.json')
      expect { config.update(cfg_import_file) }.to(
        change(Vocabulary, :count).by(1)
      )
    end

    it 'creates new vocabulary terms' do
      cfg_import_file = fixture_file_upload('config/short_vocabulary.json')
      expect { config.update(cfg_import_file) }.to(
        change(Term, :count).by(2)
      )
    end

    it 'creates new fields' do
      cfg_import_file = fixture_file_upload('config/minimal_field.json')
      expect { config.update(cfg_import_file) }.to(
        change(Field, :count).by(1)
      )
    end

    it 'updates existing vocabularies' do
      FactoryBot.create(:vocabulary, name: 'Vocab fixture for Import', description: 'TBD')
      cfg_import_file = fixture_file_upload('config/empty_vocabulary.json')
      expect { config.update(cfg_import_file) }.to(
        change { Vocabulary.last.description }.from('TBD').to('Simple test vocabulary')
      )
    end

    it 'updates existing vocabulary terms' do
      vocab = FactoryBot.create(:vocabulary, name: 'Resource Type')
      term = FactoryBot.create(:term, vocabulary: vocab, label: 'Article', note: 'TBD')
      cfg_import_file = fixture_file_upload('config/short_vocabulary.json')
      config.update(cfg_import_file)
      expect(term.reload.note).to eq 'Textual works included in a serialized publication'
    end

    it 'updates existing fields' do
      FactoryBot.create(:field, name: 'New Field', source_field: 'TBD')
      cfg_import_file = fixture_file_upload('config/minimal_field.json')
      expect { config.update(cfg_import_file) }.to(
        change { Field.last.source_field }.from('TBD').to('new_field_tesim')
      )
    end
  end
end
