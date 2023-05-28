require 'rails_helper'

RSpec.describe 'themes/show' do
  let(:theme)  { FactoryBot.create(:theme, active: false) }

  before do
    assign(:theme, theme)
  end

  it 'displays the theme label', :aggregate_failures do
    render
    expect(rendered).to match(/Theme Label/)
  end

  it 'renders theme management controls (as a partial)' do
    render
    expect(rendered).to have_selector('div.theme-controls')
  end
end
