require 'rails_helper'

RSpec.describe 'devise/invitations/new' do
  # The view depends on controller methods defined in Devise::InvitationsController
  # There are a number of ways to inject these, this seemed cleanest
  # For additonal background see:
  # https://github.com/rspec/rspec-mocks/pull/1104/files
  # https://stackoverflow.com/questions/14426746/testing-devise-views-with-rspec
  # https://github.com/rspec/rspec-rails/issues/1219
  before do
    without_partial_double_verification do
      # Stub DeviseController .resource methods
      allow(view).to receive(:resource).and_return(User.new)
      allow(view).to receive(:resource_name).and_return(:user)
    end
  end

  it 'renders new user form' do
    render
    expect(rendered).to have_selector("form[@action='#{user_invitation_path}']")
  end

  it 'accepts an e-mail' do
    render
    expect(rendered).to have_field(id: 'user_email')
  end

  it 'accepts a display name' do
    render
    expect(rendered).to have_field(id: 'user_display_name')
  end

  it 'has an option to select an initial role' do
    render
    expect(rendered).to have_select(id: 'user_role_ids')
  end

  it 'has a submit button' do
    render
    expect(rendered).to have_button(type: 'submit')
  end
end
