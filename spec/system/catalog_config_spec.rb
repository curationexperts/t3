require 'rails_helper'

RSpec.describe 'Catalog Config' do
  let(:field_seeds) do
    [{ name: 'Title', data_type: 'text_en', list_view: true, item_view: true },
     { name: 'Identifier',  data_type: 'string',  list_view: true,  item_view: true },
     { name: 'Description', data_type: 'text_en', list_view: false, item_view: true, multiple: true },
     { name: 'Keywords',    data_type: 'string',  list_view: false, item_view: true, multiple: true, facetable: true },
     { name: 'Usage Notes', data_type: 'text_en', list_view: false, item_view: true, multiple: true }]
  end

  # Stub out a minimal solr server
  let(:solr_client) { instance_double RSolr::Client }
  let(:admin_info) { { 'lucene' => { 'solr-spec-version' => '9.2.1' } } }

  before do
    allow(RSolr).to receive(:connect).and_return(solr_client)
    allow(solr_client).to receive(:get).and_return(admin_info)
    field_seeds.each do |seed|
      Field.create!(seed)
    end
    Config.current
  end

  it 'sets CatalogController index fields from the current Config' do
    # Get the name => lable pairs from the catalog controller
    index_fields = CatalogController.blacklight_config.index_fields.map { |_k, v| [v.field, v.label] }
    expect(index_fields).to eq([
                                 ['title_tesi', 'Title'],
                                 ['identifier_ssi', 'Identifier']
                               ])
  end

  it 'sets CatalogController show fields from the current Config' do
    # Get the name => lable pairs from the catalog controller
    show_fields = CatalogController.blacklight_config.show_fields.map { |_k, v| [v.field, v.label] }
    expect(show_fields).to eq([
                                ['title_tesi', 'Title'],
                                ['identifier_ssi', 'Identifier'],
                                ['description_tesim', 'Description'],
                                ['keywords_ssim', 'Keywords'],
                                ['usage_notes_tesim', 'Usage Notes']
                              ])
  end

  it 'sets CatalogController facet fields from the current Config' do
    # Get the name => lable pairs from the catalog controller
    show_fields = CatalogController.blacklight_config.facet_fields.map { |_k, v| [v.field, v.label] }
    expect(show_fields).to eq([
                                ['keywords_ssim', 'Keywords']
                              ])
  end
end
