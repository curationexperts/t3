require 'rails_helper'

RSpec.describe 'blueprints/index' do
  before do
    assign(:blueprints, [
             Blueprint.create!(
               name: 'Name'
             ),
             Blueprint.create!(
               name: 'Name'
             )
           ])
  end

  it 'renders a list of blueprints' do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new('Name'.to_s), count: 2
  end
end
