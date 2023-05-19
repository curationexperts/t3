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

  it 'renders a list of themes' do # rubocop:todo RSpec/ExampleLength
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new('Label'.to_s), count: 2
    assert_select cell_selector, text: Regexp.new('Site Name'.to_s), count: 2
    assert_select cell_selector, text: Regexp.new('Header Color'.to_s), count: 2
    assert_select cell_selector, text: Regexp.new('Header Text Color'.to_s), count: 2
    assert_select cell_selector, text: Regexp.new('Background Color'.to_s), count: 2
    assert_select cell_selector, text: Regexp.new('Background Accent Color'.to_s), count: 2
  end
end
