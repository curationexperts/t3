require 'rails_helper'

RSpec.describe 'blueprints/show' do
  before do
    assign(:blueprint, Blueprint.create!(
                         name: 'Name'
                       ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Name/)
  end
end
