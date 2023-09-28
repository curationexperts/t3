require 'rails_helper'

RSpec.describe 'admin/blueprints/edit' do
  let(:blueprint) do
    FactoryBot.create(:blueprint)
  end

  before do
    assign(:blueprint, blueprint)
  end

  it 'renders the edit blueprint form' do
    render

    assert_select 'form[action=?][method=?]', blueprint_path(blueprint), 'post' do
      assert_select 'input[name=?]', 'blueprint[name]'
    end
  end
end
