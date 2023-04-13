require 'rails_helper'

RSpec.describe 'fields/index' do
  let(:field1) { FactoryBot.create(:field, name: 'field_1') }
  let(:field2) { FactoryBot.create(:field, name: 'field_2') }
  let(:blueprint) { FactoryBot.create(:blueprint, fields: [field1, field2]) }

  before do
    assign(:fields, [field1, field2])
    params[:blueprint_id] = blueprint.id
  end

  it 'renders a list of fields' do
    render

    assert_select 'div>p', text: /Name/, count: 2
    assert_select 'div>p', text: /false/, count: 4
    assert_select 'div>p', text: /Order:\s+0/, count: 2
    assert_select 'div>p', text: /Type:\s+string/, count: 2
  end
end
