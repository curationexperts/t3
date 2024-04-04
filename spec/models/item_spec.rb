require 'rails_helper'

RSpec.describe Item do
  let(:new_item) { described_class.new(metadata: basic_description) }
  let(:basic_description) do
    {
      'Title' => 'One Hundred Years of Solitute',
      'Author' => ['Márquez, Gabriel García'],
      'Date' => '1967'
    }
  end
  let(:solr_doc) do
    {
      'blueprint_ssi' => 'Sample Blueprint',
      'title_tesi' => 'One Hundred Years of Solitute',
      'author_tesim' => ['Márquez, Gabriel García'],
      'date_ltsi' => '1967'
    }
  end

  describe '#metadata' do
    it 'defaults to an empty hash' do
      expect(described_class.new.metadata).to eq({})
    end

    it 'accepts JSON' do
      new_item.metadata = basic_description.as_json
      expect(new_item.metadata['Date']).to eq '1967'
    end
  end

  describe '#blueprint' do
    it 'refers to a Blueprint' do
      placeholder = FactoryBot.build(:blueprint)
      new_item.blueprint = placeholder
      expect(new_item).to be_valid
    end

    it 'must have a value' do
      new_item.blueprint = nil
      expect(new_item).not_to be_valid
    end

    it 'must be a kind of Blueprint' do
      expect { new_item.blueprint = 'not a blueprint' }.to raise_exception ActiveRecord::AssociationTypeMismatch
    end
  end

  describe '#to_solr' do
    let(:blueprint) { FactoryBot.build(:blueprint, name: 'Sample Blueprint') }
    let(:new_item) { described_class.new(blueprint: blueprint, metadata: basic_description.as_json) }

    it 'generates a solr document' do
      allow(blueprint).to receive(:fields).and_return(
        [FactoryBot.build(:field, name: 'Title', data_type: 'text_en'),
         FactoryBot.build(:field, name: 'Author', data_type: 'text_en', multiple: true),
         FactoryBot.build(:field, name: 'Date', data_type: 'integer')]
      )

      expect(new_item.to_solr).to include(solr_doc)
    end

    it 'uses the ActiveRecord ID as the solr ID' do
      item = FactoryBot.build(:item, id: 'placeholder_id')
      expect(item.to_solr['id']).to eq item.id
    end

    it 'inlcudes the model in its solrization' do
      expect(new_item.to_solr['model_ssi']).to eq 'Item'
    end

    it 'generates facetable versions of tokenized fields (e.g. text_en)' do
      allow(blueprint).to receive(:fields).and_return(
        [FactoryBot.build(:field, name: 'Author', data_type: 'text_en', facetable: true, multiple: true)]
      )

      expect(new_item.to_solr).to include({ 'author_tesim' => ['Márquez, Gabriel García'],
                                            'author_sim' => ['Márquez, Gabriel García'] })
    end

    it 'skips faceting tokenized fields when not specified' do
      allow(blueprint).to receive(:fields).and_return(
        [FactoryBot.build(:field, name: 'Author', data_type: 'text_en', facetable: false, multiple: true)]
      )

      expect(new_item.to_solr).not_to include('author_sim')
    end
  end

  describe '#save' do
    let(:blueprint) { FactoryBot.build(:blueprint) }
    let(:new_item) { described_class.new(blueprint: blueprint, metadata: basic_description.as_json) }

    before do
      # Stub solr calls which are tested elsewhere
      allow(new_item).to receive(:update_index)
    end

    it 'saves successfully' do
      expect { new_item.save! }.to change(described_class, :count).by(1)
    end

    it 'validates metadata is present' do
      new_item.metadata = nil
      new_item.save
      expect(new_item.errors.where(:metadata, :blank)).to be_present
    end

    it 'validates required fields' do
      allow(blueprint).to receive(:fields).and_return(
        [FactoryBot.build(:field, name: 'Required', required: true)]
      )

      new_item.save
      expect(new_item.errors.where(:required, :blank)).to be_present
    end

    it 'diregards empty field values' do
      allow(blueprint)
        .to receive(:fields).and_return([FactoryBot.build(:field, name: 'Author', multiple: true)])
      new_item.metadata['Author'] = [nil, 'Author', {}, 'Co-Author', '', 'Editor']
      new_item.save!
      expect(new_item.metadata['Author']).to eq ['Author', 'Co-Author', 'Editor']
    end
  end

  describe '#update_index', :solr do
    let(:item) { FactoryBot.build(:item) }
    let(:solr_client) { RSolr::Client.new(nil) }

    # Fake a minimal Solr server
    before do
      stub_solr
    end

    it 'gets called when saving an item' do
      allow(item).to receive(:update_index)
      item.save!
      expect(item).to have_received(:update_index)
    end

    it 'sends documents to Solr' do
      allow(item).to receive(:save)
      item.update_index
      expect(solr_client).to have_received(:update)
        .with(hash_including(data: { add: { doc: item.to_solr } }.to_json, params: { commit: true }))
    end

    it 'saves any unsaved changes' do
      item.metadata['Title'] = 'An Updated Title'
      item.update_index
      item.reload
      expect(item.metadata['Title']).to eq 'An Updated Title'
    end
  end

  describe '.reindex_all', :solr do
    let(:solr_client) { RSolr::Client.new(nil) }

    # Fake a minimal Solr server
    before do
      stub_solr
    end

    it 'calls solr update for each item', :aggregate_failures do
      allow(solr_client).to receive(:update)
      FactoryBot.create_list(:item, 2)
      described_class.reindex_all
      expect(solr_client).to have_received(:update)
        .with(hash_including(data: /add/)).exactly(2 * described_class.count).times # create + reindex = 2x
    end

    it 'sends a commit at the end' do
      allow(solr_client).to receive(:commit)
      FactoryBot.create_list(:item, 2)
      described_class.reindex_all
      expect(solr_client).to have_received(:commit)
    end
  end

  describe '.delete_orphans', :solr do
    let(:solr_client) { RSolr::Client.new(nil) }
    let(:items) { FactoryBot.create_list(:item, 3) }

    # Fake a minimal Solr server
    before do
      stub_solr
      solr_response = ['id', items[0].id, items[1].id, items[2].id, nil].join("\n")
      allow(solr_client).to receive(:get).with('select', any_args).and_return(solr_response)
      allow(solr_client).to receive(:delete_by_query)
      allow(solr_client).to receive(:delete_by_id)
      allow(solr_client).to receive(:commit)
    end

    it 'removes Solr docs with unmatched IDs', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
      orphan_id = items[1].delete.id

      described_class.delete_orphans
      expect(solr_client).to have_received(:delete_by_query).with("id:[ * TO #{described_class.minimum(:id)} }").ordered
      expect(solr_client).to have_received(:delete_by_id).with(array_including(orphan_id)).ordered
      expect(solr_client).to have_received(:delete_by_query).with("id:{ #{described_class.maximum(:id)} TO * ]").ordered
      expect(solr_client).to have_received(:commit).ordered
    end
  end

  describe '#delete_index', :solr do
    let(:item) { FactoryBot.build(:item, id: 123) }
    let(:solr_client) { RSolr::Client.new(nil) }

    # Fake a minimal Solr server
    before do
      stub_solr
    end

    it 'gets called when destroying an item' do
      allow(item).to receive(:delete_index)
      item.destroy
      expect(item).to have_received(:delete_index)
    end

    it 'sends a delete update to solr' do
      item.destroy
      expect(solr_client).to have_received(:update)
        .with(hash_including(data: { delete: { id: item.id } }.to_json, params: { commit: true }))
    end
  end
end
