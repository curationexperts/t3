require 'rails_helper'

RSpec.describe 'admin/blueprints/index' do
  let(:blueprints) { FactoryBot.create_list(:blueprint, 3) }

  before do
    assign(:blueprints, blueprints)
  end

  it 'renders a list of blueprints' do
    render
    expect(rendered).to have_selector('tbody .blueprint_name', count: 3)
  end

  it 'has a link to add a new blueprint' do
    render
    expect(rendered).to have_link('add_blueprint')
  end

  it 'has a link to view each blueprint' do
    render
    expect(rendered).to have_link(dom_id(blueprints[0], :view), href: blueprint_path(blueprints[0]))
  end

  it 'has a link to edit each blueprint' do
    render
    expect(rendered).to have_link(dom_id(blueprints[1], :edit), href: edit_blueprint_path(blueprints[1]))
  end

  it 'has a link to delete each blueprint', :aggregate_failures do
    render
    expect(rendered).to have_selector("form[@action='#{blueprint_path(blueprints[2])}']")
    expect(rendered).to have_button(dom_id(blueprints[2], :delete))
  end
end
