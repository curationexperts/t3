require 'rails_helper'

RSpec.describe 'Catalog Config' do
  let(:fields_as_json) do
    [{ 'attributes' =>
        { 'solr_field_name' => 'title_tsi',
          'solr_suffix' => '*_tsi',
          'display_label' => 'Title',
          'enabled' => true,
          'searchable' => true,
          'facetable' => false,
          'search_results' => true,
          'item_view' => true } },
     { 'attributes' =>
        { 'solr_field_name' => 'identifier_ssi',
          'solr_suffix' => '*_ssi',
          'display_label' => 'Identifier',
          'enabled' => true,
          'searchable' => true,
          'facetable' => false,
          'search_results' => true,
          'item_view' => true } },
     { 'attributes' =>
        { 'solr_field_name' => 'description_tsim',
          'solr_suffix' => '*_tsim',
          'display_label' => 'Description',
          'enabled' => true,
          'searchable' => true,
          'facetable' => false,
          'search_results' => false,
          'item_view' => true } },
     { 'attributes' =>
        { 'solr_field_name' => 'keywords_sim',
          'solr_suffix' => '*_sim',
          'display_label' => 'Keywords',
          'enabled' => true,
          'searchable' => false,
          'facetable' => true,
          'search_results' => false,
          'item_view' => false } },
     { 'attributes' =>
        { 'solr_field_name' => 'keywords_tsim',
          'solr_suffix' => '*_tsim',
          'display_label' => 'Keywords',
          'enabled' => true,
          'searchable' => true,
          'facetable' => false,
          'search_results' => true,
          'item_view' => true } },
     { 'attributes' =>
        { 'solr_field_name' => 'admin_notes_tsim',
          'solr_suffix' => '*_tsim',
          'display_label' => 'Admin Notes',
          'enabled' => false,
          'searchable' => true,
          'facetable' => false,
          'search_results' => true,
          'item_view' => true } },
     { 'attributes' =>
        { 'solr_field_name' => 'usage_notes_tsim',
          'solr_suffix' => '*_tsim',
          'display_label' => 'Use Restrictions',
          'enabled' => true,
          'searchable' => false,
          'facetable' => false,
          'search_results' => false,
          'item_view' => true } }]
  end

  # Stub out a minimal solr server
  let(:solr_client) { instance_double RSolr::Client }
  let(:admin_info) { { 'lucene' => { 'solr-spec-version' => '9.2.1' } } }

  before do
    allow(RSolr).to receive(:connect).and_return(solr_client)
    allow(solr_client).to receive(:get).and_return(admin_info)
    FactoryBot.create(:config, fields: fields_as_json)
  end

  it 'sets CatalogController index fields from the current Config' do
    # Get the name => lable pairs from the catalog controller
    index_fields = CatalogController.blacklight_config.index_fields.map { |_k, v| [v.field, v.label] }
    expect(index_fields).to eq([
                                 ['title_tsi', 'Title'],
                                 ['identifier_ssi', 'Identifier'],
                                 ['keywords_tsim', 'Keywords']
                               ])
  end

  it 'sets CatalogController show fields from the current Config' do
    # Get the name => lable pairs from the catalog controller
    show_fields = CatalogController.blacklight_config.show_fields.map { |_k, v| [v.field, v.label] }
    expect(show_fields).to eq([
                                ['title_tsi', 'Title'],
                                ['identifier_ssi', 'Identifier'],
                                ['description_tsim', 'Description'],
                                ['keywords_tsim', 'Keywords'],
                                ['usage_notes_tsim', 'Use Restrictions']
                              ])
  end

  it 'sets CatalogController facet fields from the current Config' do
    # Get the name => lable pairs from the catalog controller
    show_fields = CatalogController.blacklight_config.facet_fields.map { |_k, v| [v.field, v.label] }
    expect(show_fields).to eq([
                                ['keywords_sim', 'Keywords']
                              ])
  end
end
