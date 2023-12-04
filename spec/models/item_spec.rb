require 'rails_helper'

RSpec.describe Item do
  let(:new_item) { described_class.new }
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

  describe '#description' do
    it 'defaults to nil' do
      expect(new_item.description).to be_nil
    end

    it 'accepts JSON' do
      new_item.description = basic_description.as_json
      expect(new_item.description['Date']).to eq '1967'
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
    let(:new_item) { described_class.new(blueprint: blueprint, description: basic_description.as_json) }

    it 'generates a solr document' do
      allow(blueprint).to receive(:fields).and_return(
        [FactoryBot.build(:field, name: 'Title', data_type: 'text_en'),
         FactoryBot.build(:field, name: 'Author', data_type: 'text_en', multiple: true),
         FactoryBot.build(:field, name: 'Date', data_type: 'integer')]
      )

      expect(new_item.to_solr).to include(solr_doc)
    end

    it 'uses the ActiveRecord ID as the solr ID' do
      item = FactoryBot.build(:populated_item, id: 'placeholder_id')
      expect(item.to_solr['id']).to eq item.id
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

  it 'saves successfully' do
    # Stub solr calls which are tested elsewhere
    allow(new_item).to receive(:update_index)
    new_item.blueprint = FactoryBot.build(:blueprint)
    new_item.description = basic_description.as_json
    expect { new_item.save! }.to change(described_class, :count).by(1)
  end

  describe '#update_index', :solr do
    let(:item) { FactoryBot.build(:populated_item) }
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
      item.description['Title'] = 'An Updated Title'
      item.update_index
      item.reload
      expect(item.description['Title']).to eq 'An Updated Title'
    end
  end

  describe '#delete_index', :solr do
    let(:item) { FactoryBot.build(:populated_item, id: 123) }
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
