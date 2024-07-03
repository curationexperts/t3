require 'rails_helper'

RSpec.describe 'admin/terms/show' do
  let(:vocabulary) { FactoryBot.create(:vocabulary) }
  let(:term) { FactoryBot.build(:term, vocabulary: vocabulary, value: 'forty_two', note: 'usage note') }

  before do
    term.validate # use #validate to set the key
    assign(:term, term)
    assign(:vocabulary, vocabulary)
    request.path_parameters[:vocabulary_key] = vocabulary.key
    request.path_parameters[:key] = term.key
  end

  it 'displays the vocabulary name' do
    render
    expect(rendered).to have_selector('#vocabulary_label', text: vocabulary.label)
  end

  it 'displays other attributes' do
    render
    expect(rendered).to have_selector('div.term div.term_label', text: term.label)
  end
end
