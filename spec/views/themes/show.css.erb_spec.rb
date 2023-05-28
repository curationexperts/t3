require 'rails_helper'

RSpec.describe 'themes/show.css' do
  let(:theme)  { FactoryBot.create(:theme, active: false) }

  before do
    assign(:theme, theme)
  end

  it 'renders a root element' do
    render
    expect(rendered).to match(/:root {/)
  end
end
