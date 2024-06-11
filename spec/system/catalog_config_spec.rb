require 'rails_helper'

RSpec.describe 'Catalog Config' do
  let(:field_seeds) do
    [{ name: 'Title',       data_type: 'text_en', list_view: true,  item_view: true },
     { name: 'Identifier',  data_type: 'string',  list_view: true,  item_view: true },
     { name: 'Description', data_type: 'text_en', list_view: false, item_view: true, multiple: true },
     { name: 'Creator',     data_type: 'text_en', list_view: true,  item_view: true, multiple: true, facetable: true },
     { name: 'Keywords',    data_type: 'string',  list_view: false, item_view: true, multiple: true, facetable: true },
     { name: 'Usage Notes', data_type: 'text_en', list_view: false, item_view: true, multiple: true }]
    # NOTE: 'Files' --> 'files_ssm' is injected automatically to handle file attachments
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
    SolrService.current
  end

  it 'sets CatalogController title field to the first active field' do
    # Get the title field name from the catalog controller
    title_field = CatalogController.blacklight_config.index.title_field
    expect(title_field).to eq 'title_tesi'
  end

  it 'sets CatalogController index fields from the current Config' do
    # Get the name => lable pairs from the catalog controller
    index_fields = CatalogController.blacklight_config.index_fields.map { |_k, v| [v.field, v.label] }
    expect(index_fields).to eq([
                                 ['identifier_ssi', 'Identifier'],
                                 ['creator_tesim', 'Creator']
                               ])
  end

  it 'sets CatalogController show fields from the current Config' do
    # Get the name => lable pairs from the catalog controller
    show_fields = CatalogController.blacklight_config.show_fields.map { |_k, v| [v.field, v.label] }
    expect(show_fields).to eq([
                                ['identifier_ssi', 'Identifier'],
                                ['description_tesim', 'Description'],
                                ['creator_tesim', 'Creator'],
                                ['keywords_ssim', 'Keywords'],
                                ['usage_notes_tesim', 'Usage Notes'],
                                ['files_ssm', 'Files']
                              ])
  end

  it 'sets CatalogController facet fields from the current Config' do
    # Get the name => lable pairs from the catalog controller
    show_fields = CatalogController.blacklight_config.facet_fields.map { |_k, v| [v.field, v.label] }
    expect(show_fields).to eq([
                                ['creator_sim', 'Creator'],
                                ['keywords_ssim', 'Keywords']
                              ])
  end
end
