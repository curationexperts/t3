require 'rails_helper'

RSpec.describe 'admin/terms/index' do
  let(:vocabulary) { FactoryBot.create(:vocabulary) }
  let(:terms) { FactoryBot.build_list(:term, 3, vocabulary: vocabulary) }

  before do
    assign(:terms, terms)
    assign(:vocabulary, vocabulary)
    request.path_parameters[:vocabulary_key] = vocabulary.key
  end

  it 'renders a list of vocabulary/terms' do
    render
    expect(rendered).to have_selector('div.term div.term_label', count: 3)
  end

  it 'displays the vocabulary name' do
    render
    expect(rendered).to have_selector('#vocabulary_label', text: vocabulary.label)
  end
end
