require 'rails_helper'

RSpec.describe 'admin/fields/edit' do
  let(:field) { FactoryBot.build(:field, id: 1) }

  before do
    assign(:field, field)
  end

  # This test is a simepler version of the new test since they initially use the same form partial.
  # This version does less checking of default field values and should be beefed up
  # if the views are refactored in a way that does not share the same form.
  it 'has the expected form fields', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
    render
    form = Capybara.string(rendered).find("form[action=\"#{fields_path}\"][method=\"post\"]")
    expect(form).to have_field('field_name')
    expect(form).to have_select('field_type_selection')
    expect(form).to have_field('field_source_field')
    expect(form).to have_field('field_active')
    expect(form).to have_field('field_required')
    expect(form).to have_field('field_multiple')
    expect(form).to have_field('field_searchable')
    expect(form).to have_field('field_facetable')
    expect(form).to have_field('field_list_view')
    expect(form).to have_field('field_item_view')
  end

  describe 'type_selection' do
    it 'selects basic types' do
      field.data_type = 'date'
      render
      expect(rendered).to have_select('field_type_selection', selected: 'date')
    end

    it 'selects vocabularies' do
      field.data_type = 'vocabulary'
      field.vocabulary = FactoryBot.create(:vocabulary, label: 'Resource Type')
      render
      expect(rendered).to have_select('field_type_selection', selected: 'Resource Type')
    end

    it 'omits vocabulary for basic types' do
      field.data_type = 'boolean'
      field.vocabulary = FactoryBot.create(:vocabulary, label: 'Custom Terms')
      render
      expect(rendered).to have_select('field_type_selection', selected: 'boolean')
    end
  end
end
