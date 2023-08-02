require 'rails_helper'

RSpec.describe 'admin/users/new' do
  before do
    assign(:user, User.new)
  end

  it 'renders new user form' do
    render
    expect(rendered).to have_selector("form[@action='#{users_path}']")
  end

  it 'accepts an e-mail' do
    render
    expect(rendered).to have_field(id: 'user_email')
  end

  it 'accepts a display name' do
    render
    expect(rendered).to have_field(id: 'user_display_name')
  end

  it 'accepts a password' do
    allow(view).to receive(:action_name).and_return('new')
    render
    expect(rendered).to have_field(id: 'user_password')
  end

  it 'has checkboxes for available roles' do
    role_id = "user_role_ids_#{Role.last.id}"
    render
    expect(rendered).to have_unchecked_field(role_id)
  end

  it 'has a submit button' do
    render
    expect(rendered).to have_button(type: 'submit')
  end
end
