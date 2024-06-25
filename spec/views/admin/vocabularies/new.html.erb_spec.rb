require 'rails_helper'

RSpec.describe 'admin/vocabularies/new' do
  before do
    assign(:vocabulary, Vocabulary.new(
                          name: 'MyString',
                          description: 'MyString'
                        ))
  end

  it 'renders new vocabulary form' do
    render

    assert_select 'form[action=?][method=?]', vocabularies_path, 'post' do
      assert_select 'input[name=?]', 'vocabulary[name]'

      assert_select 'input[name=?]', 'vocabulary[description]'
    end
  end
end
