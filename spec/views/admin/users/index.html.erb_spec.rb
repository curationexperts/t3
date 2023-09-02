require 'rails_helper'

RSpec.describe 'admin/users/index' do
  let(:users) { (0..3).collect { |i| FactoryBot.build(:user, id: i) } }

  before { assign(:users, users) }

  it 'renders a list of users' do
    render
    expect(rendered).to have_selector('td.email', count: 4) # four users total
  end

  it 'links to the user object' do
    render
    expect(rendered).to have_selector('td.email a', text: users[1].email)
  end

  it 'displays the display_name for each user' do
    render
    expect(rendered).to have_selector('td.display_name', text: users[0].display_name)
  end

  it 'displays the last login for users' do
    users[2].current_sign_in_at = (12.days + 4.hours).ago
    render
    expect(rendered).to have_selector('span.login_timestamp', text: '12 days ago')
  end

  it 'displays the user state' do
    render
    expect(rendered).to have_selector('span.user_state', text: 'unknown')
  end

  describe 'password reset links' do
    example 'for database users' do
      render
      expect(rendered).to have_link(id: :password_reset_user_1, href: user_password_reset_path(users[1]))
    end

    example 'not for other providers' do
      users[2].provider = 'google'
      render
      expect(rendered).not_to have_link(id: :password_reset_user_2)
    end
  end

  it 'has a link to invite new users' do
    render
    expect(rendered).to have_link(:invite_user, href: new_user_invitation_path)
  end
end
