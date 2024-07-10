require 'rails_helper'

RSpec.describe Field do
  let(:field) { FactoryBot.build(:field) }

  it 'has a vaild factory' do
    expect(field).to be_valid
  end

  describe 'default values' do
    let(:new_field) { described_class.new }

    it 'sets active = true' do
      expect(new_field.active).to be true
    end

    it 'sets required == false' do
      expect(new_field.required).to be false
    end

    it 'sets multiple == false' do
      expect(new_field.multiple).to be false
    end

    it 'sets searchable == true' do
      expect(new_field.searchable).to be true
    end

    it 'sets facetable == false' do
      expect(new_field.facetable).to be false
    end

    it 'sets list_view == false' do
      expect(new_field.list_view).to be false
    end

    it 'sets item_view == true' do
      expect(new_field.item_view).to be true
    end
  end

  describe '#name' do
    it 'must have a value' do
      field.name = nil
      field.valid?
      expect(field.errors.where(:name, :blank)).to be_present
    end

    it 'must be unique (case insensitive)' do
      FactoryBot.create(:field, name: 'first-field')
      second_field = FactoryBot.build(:field, name: 'First-Field')
      second_field.valid?
      expect(second_field.errors.where(:name, :taken)).to be_present
    end

    it 'includes the field name in error messages' do
      FactoryBot.create(:field, name: 'first-field')
      second_field = FactoryBot.build(:field, name: 'First-Field')
      second_field.valid?
      expect(second_field.errors.full_messages_for(:name)).to include(/First-Field/)
    end

    it 'cannot begin with a space or dash' do
      field.name = '-a field'
      field.valid?
      expect(field.errors.where(:name, :invalid)).to be_present
    end

    it 'cannot end with a space or dash' do
      field.name = 'a field-'
      field.valid?
      expect(field.errors.where(:name, :invalid)).to be_present
    end

    it 'can contain letters, numbers, and spaces or dashes' do
      field.name = 'Field 1 search-only'
      field.valid?
      expect(field.errors.where(:name, :invalid)).not_to be_present
    end

    it 'can not contain special characters' do
      field.name = 'here&there'
      field.valid?
      expect(field.errors.where(:name, :invalid)).to be_present
    end
  end

  describe '#data_type' do
    it 'must have a value' do
      field.data_type = nil
      field.valid?
      expect(field.errors.where(:data_type, :blank)).to be_present
    end

    it 'does not accept invalid values' do
      field.data_type = 'irregular'
      field.valid?
      expect(field.errors.where(:data_type, :invalid)).to be_empty
    end

    it 'accepts defined types' do
      field.data_type = 'text_en'
      field.valid?
      expect(field.errors.where(:data_type, :invalid)).to be_empty
    end

    it 'casts to a string when read' do
      field.data_type = :text_en
      expect(field.data_type).to eq 'text_en'
    end

    it 'returns the expected #type_selection for basic types' do
      field.vocabulary = FactoryBot.build(:vocabulary, id: 321)
      field.data_type = 'integer'
      expect(field.type_selection).to eq 'integer'
    end

    it 'has a class method to return valid values' do
      expect(described_class.data_types).to be_a Hash
    end

    context 'with "vocabulary" selected' do
      before { field.data_type = 'vocabulary' }

      it 'requires a vocab value' do
        field.vocabulary = nil
        field.validate
        expect(field.errors.where(:vocabulary, :blank)).to be_present
      end

      it 'accepts vocabulary objects' do
        vocabulary = FactoryBot.build(:vocabulary)
        field.vocabulary = vocabulary
        expect(field.errors.where(:vocabulary, :blank)).to be_empty
      end

      it 'rejects other object classes' do
        vocabulary = 'A plain old string'
        expect { field.vocabulary = vocabulary }.to raise_exception ActiveRecord::AssociationTypeMismatch
      end

      it 'returns the expected #type_selection' do
        vocabulary = FactoryBot.create(:vocabulary, id: 321)
        field.vocabulary = vocabulary
        expect(field.type_selection).to eq 'vocabulary|321'
      end
    end
  end

  describe '#type_selection=' do
    it 'sets the data_type' do
      field.type_selection = 'boolean'
      expect(field.data_type).to eq 'boolean'
    end

    it 'clears the vocabulary for basic types', :aggregate_failures do
      field.vocabulary = FactoryBot.build(:vocabulary)
      expect(field.vocabulary).to be_present
      field.type_selection = 'date'
      expect(field.vocabulary).to be_blank
    end

    it 'sets the vocabualry when provided', :aggregate_failures do
      expect(field.vocabulary).to be_blank
      vocabulary = FactoryBot.create(:vocabulary)
      field.type_selection = "vocabulary|#{vocabulary.id}"
      expect(field.vocabulary).to eq vocabulary
    end

    it 'clears the vocabulary on invalid ids' do
      FactoryBot.build(:vocabulary, id: 321)
      allow(described_class).to receive(:find_by).with(id: '321').and_return(nil)
      field.type_selection = 'vocabulary|321'
      expect(field.vocabulary).to be_blank
    end
  end

  describe '#form_helper' do
    it 'is defined for each data_type' do
      described_class.data_types.each_key do |data_type|
        field.data_type = data_type
        expect(field.form_helper).to be_present, "Missing form_helper mapping for data_type: #{data_type}"
      end
    end
  end

  describe '#solr_suffix' do
    it 'ends in "m" for multivalued fields' do
      field.multiple = true
      expect(field.solr_suffix).to match(/m\z/)
    end

    it 'omits final "m" for singular fields' do
      field.multiple = false
      expect(field.solr_suffix).to match(/[^m]\z/)
    end

    it 'maps the field type' do
      field.data_type = 'date'
      expect(field.solr_suffix).to match(/\A_dt[sim]+\z/)
    end

    it 'does not tokenize strings' do
      field.data_type = 'string'
      expect(field.solr_suffix).to match(/\A_s[sim]+\z/)
    end

    it 'uses english token rules for text' do
      field.data_type = 'text_en'
      expect(field.solr_suffix).to match(/\A_te[sim]+\z/)
    end

    it 'has mappings for all field types' do
      expect(described_class.data_types.keys).to match_array described_class::TYPE_TO_SOLR.keys
    end
  end

  describe '#solr_field_name' do
    it 'returns a solr field name that matches dynamic field suffixes' do
      field.name = 'Year'
      field.data_type = 'integer'
      expect(field.solr_field_name).to eq 'year_ltsi'
    end

    it 'handles multiples' do
      field.name = 'Keyword'
      field.data_type = 'string'
      field.multiple = true
      expect(field.solr_field_name).to eq 'keyword_ssim'
    end

    it 'replaces dashes and spaces in the name with underscores' do
      field.name = 'Additional co-authors'
      field.data_type = 'text_en'
      field.multiple = true
      expect(field.solr_field_name).to eq 'additional_co_authors_tesim'
    end

    it 'is memoized' do
      memo = field.solr_field_name
      field.name = 'new_name'
      expect(field.solr_field_name).to eq memo
    end

    it 'clears memoization on save' do
      memo = field.solr_field_name
      field.name = "#{field.name} changed"
      field.save!
      expect(field.solr_field_name).not_to eq memo
    end
  end

  describe '#solr_facet_field' do
    it 'is the same as solr_field_name for non-text fields' do
      field.data_type = 'integer'
      expect(field.solr_facet_field).to eq field.solr_field_name
    end

    it 'does not tokenize text fields' do
      field.data_type = 'text_en'
      expect(field.solr_facet_field).to match(/_si\z/)
    end

    it 'respects multiple value fields' do
      field.data_type = 'text_en'
      field.multiple = true
      expect(field.solr_facet_field).to match(/_sim\z/)
    end

    it 'is memoized' do
      memo = field.solr_facet_field
      field.name = 'new_name'
      expect(field.solr_facet_field).to eq memo
    end

    it 'clears memoization on save' do
      memo = field.solr_facet_field
      field.name = "#{field.name} changed"
      field.save!
      expect(field.solr_facet_field).not_to eq memo
    end
  end

  describe '#sequence' do
    it 'gets set to the end of the list' do
      previous = FactoryBot.create(:field, sequence: 10)
      FactoryBot.create(:field)
      previous.reload # because sequence numbers may have been consolidated
      expect(described_class.last.sequence).to be > previous.sequence
    end
  end

  describe '#move' do
    let(:fields) { FactoryBot.create_list(:field, 2) }

    context 'with invalid commands' do
      it 'returns false' do
        expect(field.move(:sideways)).to be false
      end

      it 'adds an error' do
        field.move(:sideways)
        expect(field.errors.where(:sequence, :position)).to be_present
      end
    end

    describe ':up' do
      it ':moves the field toward the beginning of the sequence' do
        fields[1].move(:up)
        fields.each(&:reload)
        expect(fields[0].sequence).to be > fields[1].sequence
      end

      it 'is a no-op if the field is already at the start of the sequence', :aggregate_failures do
        expect(fields[0].sequence).to eq 1
        expect { fields[0].move(:up) }.not_to(change { described_class.order(:sequence).ids })
      end
    end

    describe ':down' do
      it 'moves the field toward the end of the sequence' do
        fields[0].move(:down)
        fields.each(&:reload)
        expect(fields[1].sequence).to be < fields[0].sequence
      end

      it 'is a no-op if the field is already at the end of the sequence', :aggregate_failures do
        expect(fields[0].sequence).to eq 1
        expect { fields[1].move(:down) }.not_to(change { described_class.order(:sequence).ids })
      end
    end

    describe ':top' do
      it 'moves the field to the top of the list' do
        fields[1].move(:top)
        fields.each(&:reload)
        expect(fields[1].sequence).to be < fields[0].sequence
      end

      it 'is a no-op if the field is already at the start of the sequence', :aggregate_failures do
        expect(fields[0].sequence).to eq 1
        expect { fields[0].move(:top) }.not_to(change { described_class.order(:sequence).ids })
      end
    end

    describe ':bottom' do
      it 'moves the field to the end of the list' do
        fields[0].move(:bottom)
        fields.each(&:reload)
        expect(fields[0].sequence).to be > fields[1].sequence
      end

      it 'is a no-op if the field is already at the end of the sequence', :aggregate_failures do
        expect(fields[0].sequence).to eq 1
        expect { fields[1].move(:down) }.not_to(change { described_class.order(:sequence).ids })
      end
    end
  end

  describe '#delete' do
    it 'updates sequence numbers' do
      fields = FactoryBot.create_list(:field, 3)

      expect { fields[0].destroy }.to change { described_class.maximum(:sequence) }.by(-1)
    end
  end

  describe '#save' do
    it 'updates the blacklight configuration' do
      allow(field).to receive(:update_catalog_controller)
      field.save!
      expect(field).to have_received(:update_catalog_controller)
    end
  end

  describe '#update_catalog_controller' do
    let(:sample_fields) do
      [FactoryBot.build(:field, name: 'field1', list_view: true, item_view: true, facetable: false),
       FactoryBot.build(:field, name: 'field2', list_view: true, item_view: false, facetable: true),
       FactoryBot.build(:field, name: 'field3', list_view: false, item_view: true, facetable: true)]
    end
    let(:blacklight_config) { Blacklight::Configuration.new }

    before do
      # Run these tests against an empty blacklight configuration
      allow(CatalogController).to receive(:blacklight_config).and_return(blacklight_config)
      # Stub Field#in_seqeuence
      allow(described_class).to receive(:in_sequence).and_return(sample_fields)
      # Mimic #in_sequence returning an  ActiveRecord::Relation instead of an Array
      without_partial_double_verification do
        allow(described_class.in_sequence).to receive(:where).and_return(sample_fields)
      end
    end

    it 'updates index fields', :aggregate_failures do
      # NOTE: the first active field is used as the title field and already displays in index and show views
      expect { field.send(:update_catalog_controller) }
        .to change { CatalogController.blacklight_config.index_fields.values.map(&:label) }
        .from([]).to(['field2'])
    end

    it 'updates show fields', :aggregate_failures do
      # NOTE: the first active field is used as the title field and already displays in index and show views
      expect { field.send(:update_catalog_controller) }
        .to change { CatalogController.blacklight_config.show_fields.values.map(&:label) }
        .from([]).to(array_including('field3'))
    end

    it 'updates facet fields', :aggregate_failures do
      expect { field.send(:update_catalog_controller) }
        .to change { CatalogController.blacklight_config.facet_fields.values.map(&:label) }
        .from([]).to(['field2', 'field3'])
    end
  end

  describe '.in_sequence' do
    it 'returns fields in sequence order' do
      fields = FactoryBot.create_list(:field, 2)
      expect(described_class.in_sequence).to eq [fields[0], fields[1]]
    end

    it 'is updated when any field is saved', :aggregate_failures do
      fields = FactoryBot.create_list(:field, 2)
      fields[0].update_attribute(:sequence, 4) # i.e. move the field to the end of the list
      expect(described_class.in_sequence).to eq [fields[1], fields[0]]
      fields << FactoryBot.create(:field)
      expect(described_class.in_sequence).to eq [fields[1], fields[0], fields[2]]
    end
  end
end
