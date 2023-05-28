require 'rails_helper'

RSpec.describe 'themes/index' do
  let(:red_theme)  { FactoryBot.create(:theme, label: 'Red Theme') }
  let(:blue_theme) { FactoryBot.create(:theme, label: 'Blue Theme') }
  let(:new_theme)  { FactoryBot.build(:theme, label: 'Add Theme') }

  before do
    assign(:themes, [red_theme, blue_theme, new_theme])
  end

  it 'displays a list of themes', :aggregate_failures do
    render
    expect(rendered).to have_selector('.theme-label .field-value', count: 3)
  end

  it 'renders theme management controls (as a partial)' do
    render
    expect(rendered).to have_selector('div.theme-controls', count: 3)
  end
end
