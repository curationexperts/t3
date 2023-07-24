require 'rails_helper'

RSpec.describe 'admin/_sidebar' do
  before do
    # Impresonate a user who can read the dashboard, but has no specific authroizations
    allow(view.controller.current_ability).to receive(:can?).and_return(false)
    allow(view.controller.current_ability).to receive(:can?).with(:read, :dashboard).and_return(true)
  end

  it 'has a status link' do
    render
    expect(rendered).to have_link(href: status_path)
  end

  describe 'roles link' do
    it 'renders for authorized users' do
      allow(view.controller.current_ability).to receive(:can?).with(:read, Role).and_return(true)
      render
      expect(rendered).to have_link(href: roles_path)
    end

    it 'is hidden from unauthorized users' do
      allow(view.controller.current_ability).to receive(:can?).with(:read, Role).and_return(false)
      render
      expect(rendered).not_to have_link(href: roles_path)
    end
  end
end
