require 'rails_helper'

RSpec.describe 'admin/vocabularies/edit' do
  let(:vocabulary) do
    Vocabulary.create!(
      label: 'MyString',
      note: 'MyString'
    )
  end

  before do
    assign(:vocabulary, vocabulary)
  end

  it 'renders the edit vocabulary form' do
    render

    assert_select 'form[action=?][method=?]', vocabulary_path(vocabulary), 'post' do
      assert_select 'input[name=?]', 'vocabulary[label]'

      assert_select 'input[name=?]', 'vocabulary[note]'
    end
  end
end
