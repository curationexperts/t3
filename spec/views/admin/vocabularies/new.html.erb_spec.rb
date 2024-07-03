require 'rails_helper'

RSpec.describe 'admin/vocabularies/new' do
  before do
    assign(:vocabulary, Vocabulary.new(
                          label: 'MyString',
                          note: 'MyString'
                        ))
  end

  it 'renders new vocabulary form' do
    render

    assert_select 'form[action=?][method=?]', vocabularies_path, 'post' do
      assert_select 'input[name=?]', 'vocabulary[label]'

      assert_select 'input[name=?]', 'vocabulary[note]'
    end
  end
end
