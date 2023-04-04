require 'rails_helper'

RSpec.describe 'blueprints/show' do
  let!(:blueprint) { FactoryBot.create(:blueprint) }
  let!(:field1) { FactoryBot.create(:field, blueprint: blueprint, name: 'field_1') }
  let!(:field2) { FactoryBot.create(:field, blueprint: blueprint, name: 'field_2') }
  let!(:field3) { FactoryBot.create(:field, blueprint: blueprint, name: 'field_3') }

  before do
    assign(:blueprint, blueprint)
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Name/)
  end

  it 'displays associated fields in order' do
    render
    expect(rendered).to match(/#{field1.name}.+#{field2.name}.+#{field3.name}/m)
  end

  it 'displays links to manage fields', :aggregate_failures do
    render
    expect(rendered).to have_link(href: edit_field_path(field1))
    expect(rendered).to have_link(href: edit_field_path(field1))
    expect(rendered).to have_link(href: new_blueprint_field_path(blueprint.id))
  end
end
