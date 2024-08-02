require 'rails_helper'

RSpec.describe 'admin/vocabularies/index' do
  let(:vocabularies) { FactoryBot.create_list(:vocabulary_with_note, 2) }

  before { assign(:vocabularies, vocabularies) }

  it 'renders a list of admin/vocabularies', :aggregate_failures do
    render
    expect(rendered).to have_selector(id: dom_id(vocabularies[0]))
    expect(rendered).to have_selector(id: dom_id(vocabularies[1]))
  end

  it 'displays the vocabulary labels' do
    vocabulary_labels = vocabularies.map(&:label)
    render
    expect(rendered).to include(*vocabulary_labels)
  end

  it 'displays the vocabulary notes' do
    vocabulary_notes = vocabularies.map(&:note)
    render
    expect(rendered).to include(*vocabulary_notes)
  end

  it 'renders markdown in notes' do
    vocabularies[1].note = '[**CommonMark**](https://commonmark.org/help/) examples'
    render
    expect(rendered).to include '<a href="https://commonmark.org/help/"><strong>CommonMark</strong></a> examples'
  end

  it 'provides links to each vocabulary' do
    render
    expect(rendered).to have_link(href: url_for(vocabularies[1]))
  end

  it 'has a link to add vocabularies' do
    render
    expect(rendered).to have_link(href: new_vocabulary_path)
  end
end
