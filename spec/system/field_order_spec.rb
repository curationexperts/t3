require 'rails_helper'

describe 'Field Order' do
  let!(:first_field) { FactoryBot.create(:field, name: 'Alpha') }
  let!(:second_field) { FactoryBot.create(:field, name: 'Beta') }

  it 'updates from the UI', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
    # Check initial order
    expect(first_field.sequence).to be < second_field.sequence

    # Confirm fields index view respects the order
    visit fields_path
    expect(page.all('#fields td.name').map(&:text)).to eq ['Alpha', 'Beta']

    # Reorder fields
    click_on "move_down_field_#{first_field.id}"
    expect(page.all('#fields td.name').map(&:text)).to eq ['Beta', 'Alpha']

    # Check Catalog configuration reflects updated field order
    show_fields = CatalogController.blacklight_config.show_fields.values.map(&:label)
    expect(show_fields).to eq ['Beta', 'Alpha']
  end
end
