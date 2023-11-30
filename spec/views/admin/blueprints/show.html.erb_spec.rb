require 'rails_helper'

RSpec.describe 'admin/blueprints/show' do
  let(:fields) { (0..2).collect { |i| FactoryBot.build(:field, id: i) } }
  let(:blueprint) { FactoryBot.create(:blueprint) }

  before do
    assign(:blueprint, blueprint)
    allow(blueprint).to receive(:fields).and_return(fields)
  end

  it 'displays the blueprint name' do
    render
    expect(rendered).to have_selector('.blueprint_name', text: blueprint.name)
  end

  it 'displays the blueprint fields' do
    render
    expect(rendered).to have_selector('#blueprint_fields .name', text: fields[1].name)
  end
end
