require 'rails_helper'

RSpec.describe 'admin/terms/edit' do
  let(:vocabulary) { FactoryBot.create(:vocabulary) }
  let(:term) { FactoryBot.build(:term, vocabulary: vocabulary, value: 'forty_two', note: 'usage note') }

  before do
    term.validate # use #validate to set the key
    assign(:term, term)
    assign(:vocabulary, vocabulary)
    request.path_parameters[:vocabulary_key] = vocabulary.key
    request.path_parameters[:key] = term.key
  end

  it 'renders the expected form fields', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
    render
    form = Capybara.string(rendered).find("form[action=\"#{term_path(term)}\"][method=\"post\"]")
    expect(form).to have_field('term_label', with: term.label)
    expect(form).to have_field('term_key', with: term.key)
    expect(form).to have_field('term_value', with: term.value)
    expect(form).to have_field('term_note', with: term.note)
    expect(form).to have_button(type: 'submit')
  end

  it 'has a link back to the vocabulary' do
    render
    expect(rendered).to have_link(href: vocabulary_path(vocabulary))
  end
end
