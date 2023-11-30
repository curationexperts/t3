require 'rails_helper'

RSpec.describe FieldConfig, :aggregate_failures do
  let(:new_field) { described_class.new }
  let(:expected_attributes) do
    [
      'solr_field_name',
      'solr_suffix',
      'enabled',
      'display_label',
      'searchable',
      'facetable',
      'list_view',
      'item_view'
    ]
  end

  it 'has expected attributes' do
    expect(new_field.attribute_names)
      .to match_array(expected_attributes)
  end

  context 'when assiged' do
    # see https://api.rubyonrails.org/classes/ActiveModel/Type/Boolean.html
    it 'coreces "enabled" to boolean' do
      new_field.enabled = 'false' # assiging a string
      expect(new_field.enabled).to be false # instead of a String
    end

    it 'coerces "searchable" to boolean' do
      new_field.searchable = :off
      expect(new_field.searchable).to be false
    end

    it 'coerces "facetable" to boolean' do
      new_field.facetable = :false # rubocop:disable Lint/BooleanSymbol
      expect(new_field.facetable).to be false
    end

    it 'coerces "list_view" to boolean' do
      new_field.list_view = 0
      expect(new_field.list_view).to be false
    end

    it 'coerces "item_view" to boolean' do
      new_field.item_view = 'F'
      expect(new_field.item_view).to be false
    end
  end

  context 'with defaults' do
    it 'enbales the field overall' do
      expect(new_field.enabled).to be true
    end

    it 'enables searching the field' do
      expect(new_field.searchable).to be true
    end

    it 'disables faceting the field' do
      expect(new_field.facetable).to be false
    end

    it 'displays the field in search results' do
      expect(new_field.list_view).to be true
    end

    it 'displays the field in single item views' do
      expect(new_field.item_view).to be true
    end
  end

  it 'populates "display_label" with suggested values' do
    field = described_class.new(solr_field_name: 'rights_statement_tesim', solr_suffix: '*_tesim')
    expect(field.display_label).to eq 'Rights Statement'
  end

  describe '#suggested_label' do
    it 'capitalizes simple field names' do
      new_field.solr_field_name = 'id'
      new_field.solr_suffix = nil
      expect(new_field.suggested_label).to eq 'Id'
    end

    it 'removes the solr suffix' do
      new_field.solr_field_name = 'creator_sim'
      new_field.solr_suffix = '*_sim'
      expect(new_field.suggested_label).to eq 'Creator'
    end

    it 'removes preceeding and trailing spaces and underscores' do
      new_field.solr_field_name = '_version_'
      new_field.solr_suffix = nil
      expect(new_field.suggested_label).to eq 'Version'
    end

    it 'humanizes snake case' do
      new_field.solr_field_name = 'workflow_state_name_ssim'
      new_field.solr_suffix = '*_ssim'
      expect(new_field.suggested_label).to eq 'Workflow State Name'
    end

    it 'humanizes camel case' do
      new_field.solr_field_name = 'hasRelatedMediaFragment_ssim'
      new_field.solr_suffix = '*_ssim'
      expect(new_field.suggested_label).to eq 'Has Related Media Fragment'
    end

    it 'handles nil solr_field_names' do
      new_field.solr_field_name = nil
      new_field.solr_suffix = nil
      expect(new_field.suggested_label).to be_nil
    end
  end

  it 'serializes to JSON' do
    field = described_class.new(solr_field_name: 'title_tesim', solr_suffix: '*_tesim')
    expect(field.as_json['attributes']).to eq({
                                                'solr_field_name' => 'title_tesim',
                                                'solr_suffix' => '*_tesim',
                                                'display_label' => 'Title',
                                                'enabled' => true,
                                                'searchable' => true,
                                                'list_view' => true,
                                                'item_view' => true,
                                                'facetable' => false
                                              })
  end

  it 'supports mass assignment' do
    field = described_class.new
    expect(field.solr_field_name).to be_nil
    expect { field.assign_attributes(solr_field_name: 'title_tesim', display_label: 'Title') }.not_to raise_exception
    expect(field.solr_field_name).to eq 'title_tesim'
  end
end
