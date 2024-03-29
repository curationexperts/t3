require 'rails_helper'

RSpec.describe 'admin/items/index' do
  before do
    assign(:items, [
             Item.new(
               blueprint: Blueprint.first,
               description: '',
               id: 'not-persisted-1'
             ),
             Item.new(
               blueprint: Blueprint.first,
               description: '',
               id: 'not-persisted-2'
             )
           ])
  end

  it 'renders a list of items' do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 6
  end
end
