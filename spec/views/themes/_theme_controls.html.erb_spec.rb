require 'rails_helper'

RSpec.describe 'themes/show' do
  let(:theme)  { FactoryBot.create(:theme, active: false) }

  before do
    assign(:theme, theme)
  end

  describe 'when in show views' do
    before do
      allow(view).to receive(:action_name).and_return('show')
    end

    it 'provides links to manage the theme', :aggregate_failures do
      render
      expect(rendered).to have_button('activate-theme')
      expect(rendered).to have_link('edit-theme')
      expect(rendered).to have_button('delete-theme')
    end

    context 'with an active theme' do
      let(:theme)  { FactoryBot.create(:theme, active: true) }

      it 'disables the activate button' do
        render
        expect(rendered).to have_button('activate-theme', disabled: true)
      end
    end
  end

  describe 'when in index views' do
    before do
      allow(view).to receive(:action_name).and_return('index')
    end

    it 'has a preview link for saved themes' do
      render
      expect(rendered).to have_link(dom_id(theme, :preview))
    end

    context 'with unsaved themes' do
      let(:theme) { FactoryBot.build(:theme, label: 'Add Theme') }

      it 'has a link to new' do
        render
        expect(rendered).to have_link('new_theme')
      end
    end
  end
end
