require 'rails_helper'

RSpec.describe 'admin/fields/show' do
  before do
    assign(:field, FactoryBot.build(:field, id: 1))
    allow(view.controller).to receive(:action_name).and_return('show')
  end

  # This is kinda testing the implementation, but acts as a guardrail for now
  it 'uses a disabled version of the new/edit form', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
    render
    form = Capybara.string(rendered).find(id: 'field_form')
    expect(form).to have_field('field_name')
    expect(form).to have_select('field_data_type')
    expect(form).to have_field('field_source_field')
    expect(form).to have_field('field_active')
    expect(form).to have_field('field_required')
    expect(form).to have_field('field_multiple')
    expect(form).to have_field('field_searchable')
    expect(form).to have_field('field_facetable')
    expect(form).to have_field('field_list_view')
    expect(form).to have_field('field_item_view')
  end
end
