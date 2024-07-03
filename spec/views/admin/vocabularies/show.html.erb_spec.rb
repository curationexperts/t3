require 'rails_helper'

RSpec.describe 'admin/vocabularies/show' do
  before do
    assign(:vocabulary, Vocabulary.create!(
                          label: 'Name',
                          note: 'Description'
                        ))
  end

  it 'renders attributes in <p>', :aggregate_failures do
    render
    expect(rendered).to match(/Label/)
    expect(rendered).to match(/Note/)
  end
end
