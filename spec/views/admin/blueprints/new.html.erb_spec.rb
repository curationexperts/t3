require 'rails_helper'

RSpec.describe 'admin/blueprints/new' do
  let(:blueprint) { Blueprint.new }

  before do
    assign(:blueprint, blueprint)
    allow(blueprint).to receive(:fields).and_return(
      [FactoryBot.build(:field, name: 'Title', data_type: 'text_en'),
       FactoryBot.build(:field, name: 'Author', data_type: 'text_en', multiple: true),
       FactoryBot.build(:field, name: 'Date', data_type: 'integer')]
    )
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
