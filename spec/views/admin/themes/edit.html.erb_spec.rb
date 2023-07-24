require 'rails_helper'

RSpec.describe 'admin/themes/edit' do
  let(:theme) do
    Theme.create!(
      label: 'MyString',
      site_name: 'MyString',
      header_color: 'MyString',
      header_text_color: 'MyString',
      background_color: 'MyString',
      background_accent_color: 'MyString'
    )
  end

  before do
    assign(:theme, theme)
  end

  it 'renders the edit theme form', :aggregate_failures do
    render

    expect(rendered).to have_field('theme_label', name: 'theme[label]')
    expect(rendered).to have_field(name: 'theme[site_name]')
    expect(rendered).to have_field('theme_main_logo', name: 'theme[main_logo]')
    expect(rendered).to have_button('commit', type: 'submit')
  end
end
