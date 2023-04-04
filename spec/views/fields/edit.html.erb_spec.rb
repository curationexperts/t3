require 'rails_helper'

RSpec.describe 'fields/edit' do
  let(:field) { FactoryBot.create(:field) }

  before do
    assign(:field, field)
    params[:blueprint_id] = field.blueprint_id
  end

  it 'renders the edit field form', :aggregate_failures do # rubocop:todo RSpec/ExampleLength
    render

    assert_select 'form[action=?][method=?]', blueprint_fields_path(field.blueprint_id), 'post' do
      assert_select 'input[name=?]', 'field[name]'

      assert_select 'input[name=?]', 'field[required]'

      assert_select 'input[name=?]', 'field[multiple]'

      assert_select 'input[name=?]', 'field[data_type]'

      assert_select 'input[name=?]', 'field[order]'
    end
  end
end
