require 'rails_helper'

RSpec.describe 'admin/blueprints/new' do
  let(:blueprint) { Blueprint.new(fields: FieldConfig.new) }

  before do
    assign(:blueprint, blueprint)
  end

  it 'renders new blueprint form' do
    render
    expect(rendered).to have_selector("form[@action='#{blueprints_path}']")
  end

  it 'accepts a name' do
    allow(controller).to receive(:action_name).and_return('new')
    render
    expect(rendered).to have_field(id: 'blueprint_name')
  end

  it 'has a submit button' do
    render
    expect(rendered).to have_button(type: 'submit')
  end
end
