require 'rails_helper'

RSpec.describe 'themes/index' do
  before do
    assign(:themes, [
             Theme.create!(
               label: 'Label',
               site_name: 'Site Name',
               header_color: 'Header Color',
               header_text_color: 'Header Text Color',
               background_color: 'Background Color',
               background_accent_color: 'Background Accent Color'
             ),
             Theme.create!(
               label: 'Label',
               site_name: 'Site Name',
               header_color: 'Header Color',
               header_text_color: 'Header Text Color',
               background_color: 'Background Color',
               background_accent_color: 'Background Accent Color'
             )
           ])
  end

  it 'renders a list of themes', :aggregate_failures do
    render
    expect(rendered).to have_selector('.theme-label .field-value', count: 2)
    expect(rendered).to have_selector('.theme-site-name .field-value', count: 2)
  end
end
