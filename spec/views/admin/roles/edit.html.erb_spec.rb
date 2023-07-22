require 'rails_helper'

RSpec.describe 'admin/roles/edit' do
  let(:role) { FactoryBot.create(:role) }

  before do
    assign(:role, role)
  end

  it 'renders new role form' do
    render
    expect(rendered).to have_selector("form[@action='#{role_path(role)}']")
  end

  it 'accepts a name' do
    render
    expect(rendered).to have_field(id: 'role_name')
  end

  it 'accepts a description' do
    render
    expect(rendered).to have_field(id: 'role_description')
  end

  it 'has a submit button' do
    render
    expect(rendered).to have_button(type: 'submit')
  end
end
