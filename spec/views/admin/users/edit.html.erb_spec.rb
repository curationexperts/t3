require 'rails_helper'

RSpec.describe 'admin/users/edit' do
  let(:user) { FactoryBot.create(:user) }

  before do
    assign(:user, user)
  end

  it 'renders new user form' do
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

  it 'has a submit button' do
    render
    expect(rendered).to have_button(type: 'submit')
  end
end
