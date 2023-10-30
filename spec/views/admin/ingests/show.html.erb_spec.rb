require 'rails_helper'

RSpec.describe 'admin/ingests/show' do
  before do
    assign(:ingest, FactoryBot.build(:ingest, id: 'dummy'))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Status/)
  end
end
