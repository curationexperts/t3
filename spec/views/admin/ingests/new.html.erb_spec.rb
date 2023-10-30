require 'rails_helper'

RSpec.describe 'admin/ingests/new' do
  before do
    assign(:ingest, FactoryBot.build(:ingest))
  end

  it 'renders new ingest form' do
    render

    assert_select 'form[action=?][method=?]', ingests_path, 'post' do
      assert_select 'input[name=?]', 'ingest[user_id]'

      assert_select 'input[name=?]', 'ingest[status]'
    end
  end
end
