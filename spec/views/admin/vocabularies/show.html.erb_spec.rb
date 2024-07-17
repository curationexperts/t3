require 'rails_helper'

RSpec.describe 'admin/vocabularies/show' do
  let(:vocabulary) { FactoryBot.build(:vocabulary_with_note) }

  before { assign(:vocabulary, vocabulary) }

  it 'displays the vocabulary label' do
    render
    expect(rendered).to include(vocabulary.label)
  end

  it 'displays the vocabulary key' do
    render
    expect(rendered).to have_field('vocabulary_key', with: vocabulary.key)
  end

  it 'displays the vocabulary note' do
    render
    expect(rendered).to include(vocabulary.note)
  end

  context 'with terms' do
    let!(:terms) { FactoryBot.create_list(:term, 2, vocabulary: vocabulary) }

    it 'displays the term count' do
      render
      expect(rendered).to have_selector('#term_count', text: '2')
    end

    it 'displays a list of terms' do
      render
      expect(rendered).to have_selector('div.term', count: 2)
    end

    it 'has a link to each term' do
      render
      expect(rendered).to have_link(href: url_for(terms[1]))
    end

    it 'has a link to add a term' do
      render
      expect(rendered).to have_link(href: new_vocabulary_term_path(vocabulary))
    end
  end
end
