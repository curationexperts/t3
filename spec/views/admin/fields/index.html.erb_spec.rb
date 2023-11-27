require 'rails_helper'

RSpec.describe 'admin/fields/index' do
  let(:fields) { FactoryBot.create_list(:field, 3) }

  before { assign(:fields, fields) }

  it 'renders a list of fields' do
    render
    expect(rendered).to have_selector('td.name', count: 3)
  end
end
