require 'rails_helper'

RSpec.describe 'admin/roles/index' do
  let(:roles) { (1..3).collect { FactoryBot.build(:role) } }

  before { assign(:roles, roles) }

  it 'renders a list of roles' do
    render
    expect(rendered).to have_selector('tr', count: 4) # roles +1 for header row
  end

  it 'links to the role name' do
    render
    expect(rendered).to have_selector('td.name a', text: roles[1].name)
  end

  it 'displays the description for each role' do
    render
    expect(rendered).to have_selector('td.description', text: roles[0].description)
  end
end
