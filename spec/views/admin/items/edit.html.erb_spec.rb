require 'rails_helper'

RSpec.describe 'admin/items/edit', :solr do
  let(:item) do
    Item.create!(
      blueprint: Blueprint.first,
      description: ''
    )
  end

  before do
    stub_solr
    assign(:item, item)
  end

  it 'renders the edit item form' do
    render

    assert_select 'form[action=?][method=?]', item_path(item), 'post' do
      assert_select 'input[name=?]', 'item[blueprint_id]'

      assert_select 'input[name=?]', 'item[description]'
    end
  end
end
