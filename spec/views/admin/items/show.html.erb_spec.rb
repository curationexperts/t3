require 'rails_helper'

RSpec.describe 'admin/items/show' do
  before do
    assign(:item, Item.new(
                    blueprint: Blueprint.first,
                    description: '',
                    id: 'not-persisted'
                  ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(//)
  end
end
