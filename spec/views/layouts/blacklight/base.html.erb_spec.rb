require 'rails_helper'

RSpec.describe 'layouts/blacklight/base' do
  let(:catalog) { CatalogController.new }
  let(:theme) { Theme.new(site_name: 'A fancy new archive', id: 1) }

  before do
    allow(view).to receive(:application_name).and_return('Test App')
    without_partial_double_verification do
      allow(view).to receive(:blacklight_config).and_return(catalog.blacklight_config)
    end

    stub_template('shared/_header_navbar.html.erb' => 'HEADER',
                  'shared/_footer.html.erb' => 'FOOTER')
    allow(Theme).to receive(:current).and_return(theme)
  end

  it 'includes the Theme site name in metadata' do
    render
    expect(rendered).to have_title('A fancy new archive')
  end

  it 'sets a favicon link' do
    render
    expect(rendered).to match(/<link rel="icon".*href=".*tenejo_knot_sm.*.png"/)
  end
end
