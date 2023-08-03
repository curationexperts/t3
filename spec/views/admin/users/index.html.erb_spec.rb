require 'rails_helper'

RSpec.describe 'admin/users/index' do
  let(:users) { (1..3).collect { FactoryBot.build(:user) } }

  before { assign(:users, users) }

  it 'renders a list of users' do
    render
    expect(rendered).to have_selector('tr', count: 4) # users +1 for header row
  end

  it 'links to the user object' do
    render
    expect(rendered).to have_selector('td.email a', text: users[1].email)
  end

  it 'displays the display_name for each user' do
    render
    expect(rendered).to have_selector('td.display_name', text: users[0].display_name)
  end

  it 'has a link to invite new users' do
    render
    expect(rendered).to have_link(:invite_user, href: new_user_invitation_path)
  end
end
