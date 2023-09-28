require 'rails_helper'

RSpec.describe 'admin/blueprints/show' do
  before do
    assign(:blueprint, FactoryBot.create(:blueprint))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Name/)
  end
end
