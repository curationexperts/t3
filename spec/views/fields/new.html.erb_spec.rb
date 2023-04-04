require 'rails_helper'

RSpec.describe 'fields/new' do
  let(:blueprint) { FactoryBot.create(:blueprint) }

  before do
    assign(:field, Field.new(
                     name: 'MyString',
                     blueprint: blueprint,
                     required: false,
                     multiple: false,
                     data_type: 1,
                     order: 1
                   ))
    params[:blueprint_id] = blueprint.id
  end

  it 'renders new field form', :aggregate_failures do # rubocop:todo RSpec/ExampleLength
    render

    assert_select 'form[action=?][method=?]', blueprint_fields_path(blueprint.id), 'post' do
      assert_select 'input[name=?]', 'field[name]'

      assert_select 'input[name=?]', 'field[required]'

      assert_select 'input[name=?]', 'field[multiple]'

      assert_select 'input[name=?]', 'field[data_type]'

      assert_select 'input[name=?]', 'field[order]'
    end
  end
end
