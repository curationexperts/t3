require 'rails_helper'

RSpec.describe 'shared/_footer' do
  it 'has a tenejo logo', :aggregate_failures do
    render
    expect(rendered).to have_selector 'img#powered_by_tenejo'
  end
end
