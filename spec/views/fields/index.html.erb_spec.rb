require 'rails_helper'

RSpec.describe 'fields/index' do
  before do
    assign(:fields, [
             FactoryBot.create(:field, name: 'field_1'),
             FactoryBot.create(:field, name: 'field_2')
           ])
  end

  it 'renders a list of fields' do
    render

    assert_select 'div>p', text: /Name/, count: 2
    assert_select 'div>p', text: /false/, count: 4
    assert_select 'div>p', text: /Order:\s+0/, count: 2
    assert_select 'div>p', text: /Type:\s+3/, count: 2
  end
end
