require 'rails_helper'

RSpec.describe 'admin/users/edit' do
  let(:user) { FactoryBot.build(:user) }

  before do
    assign(:user, user)
  end

  it 'renders new user form' do
    user.save!
    render
    expect(rendered).to have_selector("form[@action='#{user_path(user)}']")
  end

  it 'accepts an email' do
    render
    expect(rendered).to have_field(id: 'user_email')
  end

  it 'accepts a display name' do
    render
    expect(rendered).to have_field(id: 'user_display_name')
  end

  it 'does not have a password field' do
    render
    expect(rendered).not_to have_field(id: 'user_password')
  end

  it 'has a submit button' do
    render
    expect(rendered).to have_button(type: 'submit')
  end

  describe 'role checkbox' do
    let(:user) { FactoryBot.build(:super_admin) }

    it 'is checked for assigned roles' do
      # the super_admin factory should assign at least one role to the user
      role_id = "user_role_ids_#{user.roles.first.id}"
      render
      expect(rendered).to have_checked_field(role_id)
    end

    it 'is unchecked for unassigned roles' do
      # create a new role that can't be assigned to any user yet
      role_id = "user_role_ids_#{FactoryBot.create(:role).id}"
      render
      expect(rendered).to have_unchecked_field(role_id)
    end
  end
end
