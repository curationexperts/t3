require 'rails_helper'

RSpec.describe 'Search' do
  let(:field_seeds) do
    [{ name: 'Title',       data_type: 'text_en', list_view: true,  item_view: true },
     { name: 'Identifier',  data_type: 'string',  list_view: true,  item_view: true, searchable: false },
     { name: 'Description', data_type: 'text_en', list_view: false, item_view: true, multiple: true, searchable: true }]
    # NOTE: 'Files' --> 'files_ssm' is injected automatically to handle file attachments
  end

  # Stub out a minimal solr server
  let(:solr_client) { instance_double RSolr::Client }
  let(:admin_info) { { 'lucene' => { 'solr-spec-version' => '9.2.1' } } }

  before do
    allow(RSolr).to receive(:connect).and_return(solr_client)
    allow(solr_client).to receive(:get).with('/solr/admin/info/system', anything).and_return(admin_info)
    allow(solr_client).to receive(:send_and_receive)
    field_seeds.each do |seed|
      Field.create!(seed)
    end
  end

  it 'has the expected search options', :aggregate_failures do
    visit search_catalog_path
    expect(page).to have_selector('#search_field option', text: 'All Fields')
    expect(page).to have_selector('#search_field option', text: 'Title')
    expect(page).to have_selector('#search_field option', text: 'Description')
    expect(page).not_to have_selector('#search_field option', text: 'Identifier')
  end

  it 'sends the expected Solr query' do # rubocop:disable RSpec/ExampleLength
    visit search_catalog_path
    select 'Description', from: 'search_field'
    fill_in 'q', with: 'έννοιες που ψάχνω'
    click_on 'search'
    expect(solr_client).to have_received(:send_and_receive)
      .with('select', hash_including(params: hash_including(q: 'έννοιες που ψάχνω', qf: /description/)))
  end
end
