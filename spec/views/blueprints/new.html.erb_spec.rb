require 'rails_helper'

RSpec.describe 'blueprints/new' do
  before do
    assign(:blueprint, Blueprint.new(
                         name: 'MyString'
                       ))
  end

  it 'renders new blueprint form' do
    render

    assert_select 'form[action=?][method=?]', blueprints_path, 'post' do
      assert_select 'input[name=?]', 'blueprint[name]'
    end
  end
end
