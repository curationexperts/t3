require 'rails_helper'

RSpec.describe 'admin/vocabularies/index' do
  let(:vocabularies) { FactoryBot.create_list(:vocabulary, 2) }

  before { assign(:vocabularies, vocabularies) }

  it 'renders a list of admin/vocabularies' do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new('Label'.to_s), count: 2
    assert_select cell_selector, text: Regexp.new('Note'.to_s), count: 2
  end
end
