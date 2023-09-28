require 'rails_helper'

RSpec.describe 'admin/blueprints/index' do
  before do
    assign(:blueprints, FactoryBot.create_list(:blueprint, 2))
  end

  it 'renders a list of blueprints' do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new('Name'.to_s), count: 2
  end
end
