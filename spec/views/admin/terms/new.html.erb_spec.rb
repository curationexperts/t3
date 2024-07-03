require 'rails_helper'

RSpec.describe 'admin/terms/new' do
  let(:vocabulary) { FactoryBot.create(:vocabulary) }
  let(:term) { Term.new(vocabulary: vocabulary) }

  before do
    assign(:term, term)
    assign(:vocabulary, vocabulary)
    request.path_parameters[:vocabulary_key] = vocabulary.key
  end

  it 'renders the expected form fields', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
    render
    form = Capybara.string(rendered).find("form[action=\"#{vocabulary_terms_path(vocabulary)}\"][method=\"post\"]")
    expect(form).to have_field('term_label')
    expect(form).to have_field('term_key')
    expect(form).to have_field('term_value')
    expect(form).to have_field('term_note')
    expect(form).to have_button(type: 'submit')
  end
end
