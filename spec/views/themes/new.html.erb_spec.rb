require 'rails_helper'

RSpec.describe 'themes/new' do
  before do
    assign(:theme, Theme.new(
                     label: 'MyString',
                     site_name: 'MyString',
                     header_color: 'MyString',
                     header_text_color: 'MyString',
                     background_color: 'MyString',
                     background_accent_color: 'MyString'
                   ))
  end

  it 'renders new theme form' do # rubocop:todo RSpec/ExampleLength
    render

    assert_select 'form[action=?][method=?]', themes_path, 'post' do
      assert_select 'input[name=?]', 'theme[label]'

      assert_select 'input[name=?]', 'theme[site_name]'

      assert_select 'input[name=?]', 'theme[header_color]'

      assert_select 'input[name=?]', 'theme[header_text_color]'

      assert_select 'input[name=?]', 'theme[background_color]'

      assert_select 'input[name=?]', 'theme[background_accent_color]'
    end
  end
end
