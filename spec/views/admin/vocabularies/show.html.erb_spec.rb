require 'rails_helper'

RSpec.describe 'admin/vocabularies/show' do
  before do
    assign(:vocabulary, Vocabulary.create!(
                          name: 'Name',
                          description: 'Description'
                        ))
  end

  it 'renders attributes in <p>', :aggregate_failures do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Description/)
  end
end
