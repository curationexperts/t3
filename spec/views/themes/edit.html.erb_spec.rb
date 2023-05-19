require 'rails_helper'

RSpec.describe 'themes/edit' do
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

  it 'renders the edit theme form' do # rubocop:todo RSpec/ExampleLength
    render

    assert_select 'form[action=?][method=?]', theme_path(theme), 'post' do
      assert_select 'input[name=?]', 'theme[label]'

      assert_select 'input[name=?]', 'theme[site_name]'

      assert_select 'input[name=?]', 'theme[header_color]'

      assert_select 'input[name=?]', 'theme[header_text_color]'

      assert_select 'input[name=?]', 'theme[background_color]'

      assert_select 'input[name=?]', 'theme[background_accent_color]'
    end
  end
end
