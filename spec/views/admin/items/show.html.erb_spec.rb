require 'rails_helper'

RSpec.describe 'admin/items/show' do
  let(:item) { FactoryBot.build(:item, id: 1) }

  before do
    assign(:item, item)
    allow(item).to receive(:persisted?).and_return(true)
    allow(item.blueprint).to receive(:fields).and_return(
      [FactoryBot.build(:field, name: 'Title')]
    )
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(//)
  end
end
