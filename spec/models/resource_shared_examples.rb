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

  it 'validates required fields' do
    allow(blueprint).to receive(:fields).and_return([FactoryBot.build(:field, name: 'Required', required: true)])

    resource.metadata['Required'] = ['', nil, {}]
    resource.valid?
    expect(resource.errors.where(:metadata, :invalid)).to be_present
  end

  describe 'with vocabulary fields' do
    let(:vocabulary) { FactoryBot.create(:vocabulary, label: 'Test Vocab') }
    # let(:awaiting_approval) { FactoryBot.create(:term, label: 'Awaiting final approval', vocabulary: vocabulary) }
    let(:unpublished) { FactoryBot.create(:term, label: 'Unpulished Text', key: 'unpub', vocabulary: vocabulary) }

    before do
      allow(blueprint).to receive(:fields).and_return(
        [FactoryBot.build(:field, name: 'Publication Status', data_type: 'vocabulary',
                                  vocabulary: vocabulary, facetable: true, multiple: true)]
      )

      # Stub solr calls which are tested elsewhere
      allow(resource).to receive(:update_index)
    end

    example 'when terms are valid' do
      resource.metadata['Publication Status'] = [unpublished.id]
      expect(resource).to be_valid
    end

    it 'accepts ids as strings from forms' do
      resource.metadata['Publication Status'] = [unpublished.id.to_s]
      expect(resource).to be_valid
    end

    it 'accepts term keys' do
      resource.metadata['Publication Status'] = [unpublished.key]
      expect(resource).to be_valid
    end

    it 'accepts term values' do
      resource.metadata['Publication Status'] = [unpublished.label]
      expect(resource).to be_valid
    end

    it 'persists term ids' do
      resource.metadata['Publication Status'] = [unpublished.key]
      resource.save!
      resource.reload
      expect(resource.metadata['Publication Status']).to eq [unpublished.id]
    end

    it 'gives validation errors when terms are not valid' do
      # e.g. assign a term from a vocabulary not associated with the field
      foreign_term = FactoryBot.create(:term, vocabulary: FactoryBot.create(:vocabulary))
      resource.metadata['Publication Status'] = [foreign_term.id]
      resource.valid?
      expect(resource.errors.where(:metadata, :invalid)).to be_present
    end

    it 'disregards blank entries', :aggregate_failures do
      resource.metadata['Publication Status'] = [nil, '']
      expect { resource.save! }.not_to raise_exception
      resource.reload
      expect(resource.metadata['Publication Status']).to eq []
    end

    it 'filters out blank entries from non-blank values' do
      resource.metadata['Publication Status'] = ['', unpublished.id, '']
      resource.save!
      resource.reload
      expect(resource.metadata['Publication Status']).to eq [unpublished.id]
    end
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
end
