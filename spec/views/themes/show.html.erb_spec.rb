require 'rails_helper'

RSpec.describe 'themes/show' do
  before do
    assign(:theme, Theme.create!(
                     label: 'Label',
                     site_name: 'Site Name',
                     header_color: 'Header Color',
                     header_text_color: 'Header Text Color',
                     background_color: 'Background Color',
                     background_accent_color: 'Background Accent Color'
                   ))
  end

  it 'renders attributes in <p>', :aggregate_failures do # rubocop:todo RSpec/ExampleLength
    render
    expect(rendered).to match(/Label/)
    expect(rendered).to match(/Site Name/)
    expect(rendered).to match(/Header Color/)
    expect(rendered).to match(/Header Text Color/)
    expect(rendered).to match(/Background Color/)
    expect(rendered).to match(/Background Accent Color/)
  end
end
