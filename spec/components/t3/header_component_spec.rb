require 'rails_helper'

RSpec.describe T3::HeaderComponent, type: :component do
  let(:blacklight_config) { Blacklight::Configuration.new }

  it 'renders default logo' do
    theme = FactoryBot.create(:theme)
    theme.activate!
    render_inline(described_class.new(blacklight_config: blacklight_config))
    expect(page).to have_selector 'img[src*="blacklight/logo"]'
    # logo_src = page.find('//body//a.navbar-logo/img')['src']
    # expect(logo_src).to match 'blacklight/logo-.*\.png'
  end

  it 'renders custom logo when present' do
    theme = FactoryBot.create(:theme, :with_logo)
    theme.activate!
    render_inline(described_class.new(blacklight_config: blacklight_config))
    expect(page).to have_selector 'img[src*="sample_logo.png"]'
  end
end
