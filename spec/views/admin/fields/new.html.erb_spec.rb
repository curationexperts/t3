require 'rails_helper'

RSpec.describe 'admin/fields/new' do
  before do
    assign(:field, Field.new)
  end

  it 'has the expected form fields', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
    render
    form = Capybara.string(rendered).find("form[action=\"#{fields_path}\"][method=\"post\"]")
    expect(form).to have_field('field_name')
    expect(form).to have_select('field_type_selection', with_options: ['string', 'integer', 'collection'])
    expect(form).to have_field('field_source_field')
    expect(form).to have_checked_field('field_active')
    expect(form).to have_unchecked_field('field_required')
    expect(form).to have_unchecked_field('field_multiple')
    expect(form).to have_field('field_searchable')
    expect(form).to have_field('field_facetable')
    expect(form).to have_unchecked_field('field_list_view')
    expect(form).to have_checked_field('field_item_view')
  end
end
