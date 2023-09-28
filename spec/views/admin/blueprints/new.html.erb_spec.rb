require 'rails_helper'

RSpec.describe 'admin/blueprints/new' do
  before do
    assign(:blueprint, Blueprint.new)
  end

  it 'renders new blueprint form' do
    render
    expect(rendered).to have_selector("form[@action='#{blueprints_path}']")
  end

  it 'accepts a name' do
    render
    expect(rendered).to have_field(id: 'blueprint_name')
  end

  it 'has a submit button' do
    render
    expect(rendered).to have_button(type: 'submit')
  end
end
