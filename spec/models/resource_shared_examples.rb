# Shared examples to include for classes that inherit from the Resource class
RSpec.shared_examples 'a resource' do
  let(:resource) { described_class.new(blueprint: blueprint, metadata: basic_description.as_json) }
  let(:blueprint) { FactoryBot.create(:blueprint, name: 'Sample Blueprint') }
  let(:basic_description) do
    {
      'Title' => 'One Hundred Years of Solitude',
      'Author' => ['Márquez, Gabriel García'],
      'Date' => '1967'
    }
  end

  it 'behaves like an Resource' do
    expect(resource).to be_a(Resource)
  end

  it 'uses Single Table Inheritance' do
    expect(resource.class.table_name).to eq 'resources'
  end

  describe '#metadata' do
    it 'defaults to an empty hash' do
      expect(described_class.new.metadata).to eq({})
    end

    it 'accepts JSON' do
      resource.metadata = basic_description.as_json
      expect(resource.metadata['Date']).to eq '1967'
    end
  end

  describe '#blueprint' do
    it 'refers to a Blueprint' do
      placeholder = FactoryBot.build(:blueprint)
      resource.blueprint = placeholder
      expect(resource).to be_valid
    end

    it 'must have a value', :aggregate_failures do
      expect(resource).to be_valid
      resource.blueprint = nil
      expect(resource).not_to be_valid
      expect(resource.errors.where(:blueprint, :blank)).to be_present
    end

    it 'must be a kind of Blueprint' do
      expect { resource.blueprint = 'not a blueprint' }.to raise_exception ActiveRecord::AssociationTypeMismatch
    end
  end

  describe '#label' do
    it 'returns the value of the bluprint title field' do
      allow(blueprint).to receive(:fields).and_return(
        [FactoryBot.build(:field, name: 'Title', data_type: 'text_en')]
      )
      expect(resource.label).to eq 'One Hundred Years of Solitude'
    end

    it 'returns the id when the title field is empty' do
      # No "title" field is defined if there are no fields
      allow(blueprint).to receive(:fields).and_return([])
      resource.id = 987

      expect(resource.label).to eq "#{resource.class}(987)"
    end
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

  it 'validates required fields' do
    allow(blueprint).to receive(:fields).and_return([FactoryBot.build(:field, name: 'Required', required: true)])

    resource.metadata['Required'] = ['', nil, {}]
    resource.valid?
    expect(resource.errors.where(:metadata, :invalid)).to be_present
  end

  describe '#save' do
    before do
      # Stub solr calls which are tested elsewhere
      allow(resource).to receive(:update_index)
    end

    it 'saves successfully' do
      expect { resource.save! }.to change(described_class, :count).by(1)
    end

    it 'validates metadata is present' do
      resource.metadata = nil
      resource.save
      expect(resource.errors.where(:metadata, :blank)).to be_present
    end

    it 'diregards empty field values' do
      allow(blueprint)
        .to receive(:fields).and_return([FactoryBot.build(:field, name: 'Author', multiple: true)])
      resource.metadata['Author'] = [nil, 'Author', {}, 'Co-Author', '', 'Editor']
      resource.save!
      expect(resource.metadata['Author']).to eq ['Author', 'Co-Author', 'Editor']
    end

    it 'casts scalars for multi-valued fields' do
      allow(blueprint)
        .to receive(:fields).and_return([FactoryBot.build(:field, name: 'Author', multiple: true)])
      resource.metadata['Author'] = 'scalar'
      resource.save!
      expect(resource.metadata['Author']).to be_an(Array)
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
