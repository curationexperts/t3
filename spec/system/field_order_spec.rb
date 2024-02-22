require 'rails_helper'

describe 'Field Order' do
  let!(:first_field)  { FactoryBot.create(:field, name: 'Alpha') }
  let!(:second_field) { FactoryBot.create(:field, name: 'Beta') }
  let!(:third_field)  { FactoryBot.create(:field, name: 'Gamma') }

  it 'updates from the UI', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
    # Check initial order
    expect(first_field.sequence).to be < second_field.sequence
    expect(second_field.sequence).to be < third_field.sequence

    # Confirm fields index view respects the order
    visit fields_path
    expect(page.all('#fields td.name').map(&:text)).to eq ['Alpha', 'Beta', 'Gamma']

    # Reorder fields
    click_on "move_down_field_#{first_field.id}"
    expect(page.all('#fields td.name').map(&:text)).to eq ['Beta', 'Alpha', 'Gamma']

    # Check Catalog configuration reflects updated field order
    # NOTE: first field is used as the title field and suppressed from index_fields and show_fields
    show_fields = CatalogController.blacklight_config.show_fields.values.map(&:label)
    expect(show_fields).to eq ['Alpha', 'Gamma']
  end
end
