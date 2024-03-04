require 'rails_helper'

RSpec.describe 'layouts/blacklight/base' do
  let(:catalog) { CatalogController.new }

  before do
    allow(view).to receive(:controller).and_return(catalog)
    allow(view).to receive(:application_name).and_return('Test App')
    allow(catalog).to receive(:request).and_return(request)

    stub_template('shared/_header_navbar.html.erb' => 'HEADER',
                  'shared/_footer.html.erb' => 'FOOTER')
  end

  it 'includes the Theme site name in metadata' do
    allow(Theme.current).to receive(:site_name).and_return('A fancy new archive')

    render
    expect(rendered).to have_title('A fancy new archive')
  end

  it 'sets a favicon link' do
    render
    expect(rendered).to match(/<link rel="icon".*href=".*tenejo_knot_sm.png"/)
  end
end
