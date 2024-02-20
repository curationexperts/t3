require 'rails_helper'

RSpec.describe 'admin/ingests/index' do
  let(:ingests) { (1..3).collect { |i| FactoryBot.build(:ingest, id: i) } }

  before { assign(:ingests, ingests) }

  it 'renders a list of ingests' do
    render
    expect(rendered).to have_selector('td.owner', count: 3)
  end

  it 'links to the individual batch' do
    render
    expect(rendered).to have_link('view', href: url_for(ingests[1]))
  end

  it 'links to the manifest' do
    render
    expect(rendered).to have_selector('td.manifest a', text: ingests[1].manifest.filename)
  end

  it 'links to the report' do
    ingests[2].report = Rack::Test::UploadedFile.new('spec/fixtures/files/report.json', 'application/json')
    render
    expect(rendered).to have_selector('td.report a', text: ingests[1].report.filename)
  end

  it 'displays the display_name for each owner' do
    render
    expect(rendered).to have_selector('td.owner', text: ingests[0].user.display_name)
  end

  it 'displays the ingest status' do
    render
    expect(rendered).to have_selector('td.status', text: 'initialized', count: 3)
  end

  it 'has a link to create a new ingest' do
    render
    expect(rendered).to have_link(:new_ingest, href: new_ingest_path)
  end
end
