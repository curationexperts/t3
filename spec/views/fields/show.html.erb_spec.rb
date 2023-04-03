require 'rails_helper'

RSpec.describe 'fields/show' do
  before do
    assign(:field, FactoryBot.create(:field))
  end

  it 'renders attributes in <p>', :aggregate_failures do  # rubocop:todo RSpec/ExampleLength
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(//)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/0/)
    expect(rendered).to match(/3/)
  end
end
