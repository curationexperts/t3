require 'rails_helper'

RSpec.describe 'admin/items/index' do
  let(:items) do
    FactoryBot.build_list(:item, 3) { |item, i| item.id = i }
  end

  before do
    allow(view).to receive(:controller_name).and_return('items')
    assign(:items, items)
  end

  it 'renders a list of items' do
    render
    expect(rendered).to have_selector('div.resource', count: 3)
  end
end
