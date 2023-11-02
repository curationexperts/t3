require 'rails_helper'

RSpec.describe 'admin/ingests/new' do
  before do
    assign(:ingest, Ingest.new)
  end

  it 'renders new ingest form' do
    render
    expect(rendered).to have_selector("form[@action='#{ingests_path}']")
  end

  it 'accepts manifest file' do
    render
    expect(rendered).to have_field(id: 'ingest_manifest')
  end

  it 'has a submit button' do
    render
    expect(rendered).to have_button(type: 'submit')
  end
end
