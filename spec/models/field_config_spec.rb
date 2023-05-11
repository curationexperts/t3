require 'rails_helper'

RSpec.describe FieldConfig, :aggregate_failures do
  let(:new_field) { described_class.new }
  let(:expected_attributes) do
    [
      'solr_field_name',
      'enabled',
      'display_label',
      'searchable',
      'facetable',
      'search_results',
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

    it 'coerces "search_results" to boolean' do
      new_field.search_results = 0
      expect(new_field.search_results).to be false
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
      expect(new_field.search_results).to be true
    end

    it 'displays the field in single item views' do
      expect(new_field.item_view).to be true
    end
  end

  it 'populates suggested display_label values based on the solr_field_name' do
    expect(new_field.display_label).to be_nil
    new_field.solr_field_name = '__Rights-Statement_tsi'
    expect(new_field.display_label).to eq 'Rights Statement'
  end

  it 'serializes to JSON' do
    field = described_class.new(solr_field_name: 'title_tesim', display_label: 'Title')
    expect(field.as_json['attributes']).to eq({
                                                'solr_field_name' => 'title_tesim',
                                                'display_label' => 'Title',
                                                'enabled' => true,
                                                'searchable' => true,
                                                'search_results' => true,
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
