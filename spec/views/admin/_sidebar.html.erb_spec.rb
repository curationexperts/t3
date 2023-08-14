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

  describe 'users link' do
    it 'renders for authorized users' do
      allow(view.controller.current_ability).to receive(:can?).with(:read, User).and_return(true)
      render
      expect(rendered).to have_link(href: users_path)
    end

    it 'is hidden from unauthorized users' do
      allow(view.controller.current_ability).to receive(:can?).with(:read, User).and_return(false)
      render
      expect(rendered).not_to have_link(href: users_path)
    end
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

  describe 'themes link' do
    it 'renders for authorized users' do
      allow(view.controller.current_ability).to receive(:can?).with(:read, Theme).and_return(true)
      render
      expect(rendered).to have_link(href: themes_path)
    end

    it 'is hidden from unauthorized users' do
      allow(view.controller.current_ability).to receive(:can?).with(:read, Theme).and_return(false)
      render
      expect(rendered).not_to have_link(href: themes_path)
    end
  end

  describe 'config link' do
    it 'renders for authorized users' do
      allow(view.controller.current_ability).to receive(:can?).with(:read, Config).and_return(true)
      render
      expect(rendered).to have_link(href: configs_path)
    end

    it 'is hidden from unauthorized users' do
      allow(view.controller.current_ability).to receive(:can?).with(:read, Config).and_return(false)
      render
      expect(rendered).not_to have_link(href: configs_path)
    end
  end

  describe 'domains link' do
    it 'renders for authorized users' do
      allow(view.controller.current_ability).to receive(:can?).with(:read, CustomDomain).and_return(true)
      render
      expect(rendered).to have_link(href: custom_domains_path)
    end

    it 'is hidden from unauthorized users' do
      allow(view.controller.current_ability).to receive(:can?).with(:read, CustomDomain).and_return(false)
      render
      expect(rendered).not_to have_link(href: custom_domains_path)
    end
  end
end
