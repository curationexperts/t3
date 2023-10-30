require 'rails_helper'

RSpec.describe 'admin/ingests/edit' do
  let(:ingest) { FactoryBot.create(:ingest) }

  before do
    assign(:ingest, ingest)
  end

  it 'renders the edit ingest form' do
    render

    assert_select 'form[action=?][method=?]', ingest_path(ingest), 'post' do
      assert_select 'input[name=?]', 'ingest[user_id]'

      assert_select 'input[name=?]', 'ingest[status]'
    end
  end
end
