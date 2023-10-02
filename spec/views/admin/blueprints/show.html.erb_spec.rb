require 'rails_helper'

RSpec.describe 'admin/blueprints/show' do
  let(:fields) { (0..2).map { FactoryBot.build(:field_config) } }
  let(:blueprint) { FactoryBot.create(:blueprint, fields: fields) }

  before do
    assign(:blueprint, blueprint)
  end

  it 'displays the blueprint name' do
    render
    expect(rendered).to have_selector('.blueprint_name', text: blueprint.name)
  end

  it 'displays the blueprint fields' do
    render
    expect(rendered).to have_selector('#blueprint_fields .display_label', text: fields[1].display_label)
  end
end
