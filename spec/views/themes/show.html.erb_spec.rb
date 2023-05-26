require 'rails_helper'

RSpec.describe 'themes/show' do
  let(:theme)  { FactoryBot.create(:theme, active: false) }

  before do
    assign(:theme, theme)
  end

  it 'renders attributes', :aggregate_failures do
    render
    expect(rendered).to match(/Theme Label/)
    expect(rendered).to match(/My Site/)
    expect(rendered).to match(/#000000/)
  end

  it 'has links to manage the theme', :aggregate_failures do
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
