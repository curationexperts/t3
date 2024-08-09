require 'rails_helper'

RSpec.describe CatalogConfigService do
  describe '.update_catalog_controller' do
    let(:sample_fields) do
      [FactoryBot.build(:field, name: 'field1', list_view: true, item_view: true, searchable: true, facetable: false),
       FactoryBot.build(:field, name: 'field2', list_view: true, item_view: false, searchable: false, facetable: true),
       FactoryBot.build(:field, name: 'field3', list_view: false, item_view: true, searchable: true, facetable: true)]
    end
    let(:blacklight_config) { Blacklight::Configuration.new }

    before do
      # Run these tests against an empty blacklight configuration
      allow(CatalogController).to receive(:blacklight_config).and_return(blacklight_config)
      # Stub Field#in_seqeuence
      allow(Field).to receive(:in_sequence).and_return(sample_fields)
      # Mimic #in_sequence returning an  ActiveRecord::Relation instead of an Array
      without_partial_double_verification do
        allow(Field.in_sequence).to receive(:where).and_return(sample_fields)
      end
    end

    it 'updates index fields', :aggregate_failures do
      # NOTE: the first active field is used as the title field and already displays in index and show views
      expect { described_class.send(:update_catalog_controller) }
        .to change { CatalogController.blacklight_config.index_fields.values.map(&:label) }
        .from([]).to(['field2'])
    end

    it 'updates show fields', :aggregate_failures do
      # NOTE: the first active field is used as the title field and already displays in index and show views
      expect { described_class.send(:update_catalog_controller) }
        .to change { CatalogController.blacklight_config.show_fields.values.map(&:label) }
        .from([]).to(array_including('field3'))
    end

    it 'updates facet fields', :aggregate_failures do
      expect { described_class.send(:update_catalog_controller) }
        .to change { CatalogController.blacklight_config.facet_fields.values.map(&:label) }
        .from([]).to(['field2', 'field3'])
    end
  end
end
