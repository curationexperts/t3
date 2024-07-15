# Shared examples to include for classes that inherit from the Resource class
RSpec.shared_examples 'an indexed resource' do
  let(:resource) { described_class.new(blueprint: blueprint, metadata: basic_description.as_json) }
  let(:blueprint) { FactoryBot.create(:blueprint, name: 'Sample Blueprint') }
  let(:basic_description) do
    {
      'Title' => 'One Hundred Years of Solitude',
      'Author' => ['Márquez, Gabriel García'],
      'Date' => '1967'
    }
  end

  describe '#to_solr' do
    it 'generates a solr document' do
      allow(blueprint).to receive(:fields).and_return(
        [FactoryBot.build(:field, name: 'Title', data_type: 'text_en'),
         FactoryBot.build(:field, name: 'Author', data_type: 'text_en', multiple: true),
         FactoryBot.build(:field, name: 'Date', data_type: 'integer')]
      )

      expect(resource.to_solr).to include(
        'blueprint_ssi' => 'Sample Blueprint',
        'title_tesi' => 'One Hundred Years of Solitude',
        'author_tesim' => ['Márquez, Gabriel García'],
        'date_ltsi' => '1967'
      )
    end

    it 'uses the ActiveRecord ID as the solr ID' do
      resource = described_class.new(id: 'placeholder_id', blueprint: blueprint)
      expect(resource.to_solr['id']).to eq resource.id
    end

    it 'inlcudes the model in its solrization' do
      expect(resource.to_solr['model_ssi']).to eq described_class.name
    end

    it 'generates facetable versions of tokenized fields (e.g. text_en)' do
      allow(blueprint).to receive(:fields).and_return(
        [FactoryBot.build(:field, name: 'Author', data_type: 'text_en', facetable: true, multiple: true)]
      )

      expect(resource.to_solr).to include({ 'author_tesim' => ['Márquez, Gabriel García'],
                                            'author_sim' => ['Márquez, Gabriel García'] })
    end

    it 'skips faceting tokenized fields when not specified' do
      allow(blueprint).to receive(:fields).and_return(
        [FactoryBot.build(:field, name: 'Author', data_type: 'text_en', facetable: false, multiple: true)]
      )

      expect(resource.to_solr).not_to include('author_sim')
    end
  end

  context 'with vocabularies' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:vocabulary) { FactoryBot.create(:vocabulary, label: 'Test Vocab') }
    let(:awaiting_approval) { FactoryBot.create(:term, label: 'Awaiting final approval', vocabulary: vocabulary) }
    let(:unpublished) { FactoryBot.create(:term, label: 'Unpulished Text', vocabulary: vocabulary) }
    let(:illuminated) { FactoryBot.create(:term, label: 'Illuminated Manuscript', vocabulary: vocabulary) }

    it 'indexes single-value term labels & ids' do
      allow(blueprint).to receive(:fields).and_return(
        [FactoryBot.build(:field, name: 'Publication Status', data_type: 'vocabulary',
                                  vocabulary: vocabulary, facetable: true, multiple: false)]
      )

      resource.metadata['Publication Status'] = awaiting_approval.id
      expect(resource.to_solr).to include({ 'publication_status_ssi' => 'Awaiting final approval',
                                            'publication_status_ids_lsim' => [awaiting_approval.id] })
    end

    it 'indexes multi-value term labels & ids' do
      allow(blueprint).to receive(:fields).and_return(
        [FactoryBot.build(:field, name: 'Resource Type', data_type: 'vocabulary',
                                  vocabulary: vocabulary, facetable: true, multiple: true)]
      )

      resource.metadata['Resource Type'] = [unpublished.id, illuminated.id]
      expect(resource.to_solr).to include({ 'resource_type_ssim' => ['Unpulished Text', 'Illuminated Manuscript'],
                                            'resource_type_ids_lsim' => [unpublished.id, illuminated.id] })
    end
  end

  describe '#update_index', :solr do
    let(:resource) { FactoryBot.build(described_class.name.underscore.to_sym) }
    let(:solr_client) { RSolr::Client.new(nil) }

    # Fake a minimal Solr server
    before do
      stub_solr
    end

    it 'gets called when saving a resource' do
      allow(resource).to receive(:update_index)
      resource.save!
      expect(resource).to have_received(:update_index)
    end

    it 'sends documents to Solr' do
      allow(resource).to receive(:save)
      resource.update_index
      expect(solr_client).to have_received(:update)
        .with(hash_including(data: { add: { doc: resource.to_solr } }.to_json,
                             params: { commit: true }))
    end

    it 'saves any unsaved changes' do
      resource.metadata['Title'] = 'An Updated Title'
      resource.update_index
      resource.reload
      expect(resource.metadata['Title']).to eq 'An Updated Title'
    end
  end

  describe '.reindex_all', :solr do
    let(:solr_client) { RSolr::Client.new(nil) }

    # Fake a minimal Solr server
    before do
      stub_solr
    end

    it 'calls solr update for each resource', :aggregate_failures do
      allow(solr_client).to receive(:update)
      FactoryBot.create_list(described_class.name.underscore.to_sym, 2)
      described_class.reindex_all
      expect(solr_client).to have_received(:update)
        .with(hash_including(data: /add/)).exactly(2 * described_class.count).times # create + reindex = 2x
    end

    it 'sends a commit at the end' do
      allow(solr_client).to receive(:commit)
      FactoryBot.create_list(described_class.name.underscore.to_sym, 2)
      described_class.reindex_all
      expect(solr_client).to have_received(:commit)
    end
  end

  describe '.delete_orphans', :solr do
    let(:solr_client) { RSolr::Client.new(nil) }
    let(:resources) { FactoryBot.create_list(described_class.name.underscore.to_sym, 3) }

    # Fake a minimal Solr server
    before do
      stub_solr
      solr_response = ['id', resources[0].id, resources[1].id, resources[2].id, nil].join("\n")
      allow(solr_client).to receive(:get).with('select', any_args).and_return(solr_response)
      allow(solr_client).to receive(:delete_by_query)
      allow(solr_client).to receive(:delete_by_id)
      allow(solr_client).to receive(:commit)
    end

    it 'removes Solr docs with unmatched IDs', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
      orphan_id = resources[1].delete.id

      described_class.delete_orphans
      expect(solr_client).to have_received(:delete_by_query).with("id:[ * TO #{described_class.minimum(:id)} }").ordered
      expect(solr_client).to have_received(:delete_by_id).with(array_including(orphan_id)).ordered
      expect(solr_client).to have_received(:delete_by_query).with("id:{ #{described_class.maximum(:id)} TO * ]").ordered
      expect(solr_client).to have_received(:commit).ordered
    end
  end

  describe '#delete_index', :solr do
    let(:resource) { FactoryBot.create(described_class.name.underscore.to_sym) }
    let(:solr_client) { RSolr::Client.new(nil) }

    # Fake a minimal Solr server
    before do
      stub_solr
    end

    it 'gets called when destroying a resource' do
      allow(resource).to receive(:delete_index)
      resource.destroy
      expect(resource).to have_received(:delete_index)
    end

    it 'sends a delete update to solr' do
      resource.destroy
      expect(solr_client).to have_received(:update)
        .with(hash_including(data: { delete: { id: resource.id } }.to_json,
                             params: { commit: true }))
    end
  end
end
