require 'rails_helper'

RSpec.describe 'admin/roles/show' do
  let(:role) do
    FactoryBot.create(:role, name: 'My Role',
                             description: 'It was the best of roles, it was the worst of roles...')
  end

  before do
    assign(:role, role)
  end

  it 'displays the role name' do
    render
    expect(rendered).to have_selector('.name', text: 'My Role')
  end

  it 'displays the role description' do
    render
    expect(rendered).to have_selector('.description', text: 'the best of roles')
  end
end
