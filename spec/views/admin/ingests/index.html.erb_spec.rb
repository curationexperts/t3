require 'rails_helper'

RSpec.describe 'admin/ingests/index' do
  before do
    assign(:ingests, FactoryBot.build_list(:ingest, 2))
  end

  it 'renders a list of ingests' do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new('User'), count: 2
    assert_select cell_selector, text: Regexp.new('Status'), count: 2
  end
end
