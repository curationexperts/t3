require 'rails_helper'

RSpec.describe 'admin/users/show' do
  let(:user) { FactoryBot.create(:user) }
  let(:role) { FactoryBot.create(:role, users: [user]) }

  before do
    assign(:user, user)
  end

  it 'displays the user email' do
    render
    expect(rendered).to have_selector('.user_email', text: user.email)
  end

  it 'displays the user display name' do
    render
    expect(rendered).to have_selector('.user_display_name', text: user.display_name)
  end

  it 'displays the user status' do
    render
    expect(rendered).to have_selector('.user_status', text: 'unknown')
  end

  it 'displays any associated roles' do
    render
    expect(rendered).to have_selector('.user_roles', text: user.roles.first)
  end
end
