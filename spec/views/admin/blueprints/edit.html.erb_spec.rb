require 'rails_helper'

RSpec.describe 'admin/blueprints/edit' do
  let(:fields) { (0..2).collect { |i| FactoryBot.build(:field, id: i) } }
  let(:blueprint) { FactoryBot.create(:blueprint) }

  before do
    assign(:blueprint, blueprint)
    allow(controller).to receive(:action_name).and_return('edit')
    allow(blueprint).to receive(:fields).and_return(fields)
  end

  it 'renders new blueprint form' do
    render
    expect(rendered).to have_selector("form[@action='#{blueprint_path(blueprint)}']")
  end

  it 'has a submit button' do
    render
    expect(rendered).to have_button(type: 'submit')
  end

  it 'displays the blueprint name' do
    render
    expect(rendered).to have_selector('.blueprint_name', text: blueprint.name)
  end

  describe 'fields', :aggregate_failures do
    it 'displays inputs and values for each field' do
      render
      expect(rendered).to have_field('blueprint_fields_0_name', with: fields[0].name)
      expect(rendered).to have_field('blueprint_fields_2_name', with: fields[2].name)
    end

    it 'has a button to add a field' do
      render
      expect(rendered).to have_button(type: 'submit', name: 'manage_field[add_field]')
    end

    it 'has a button do delete each field' do
      render
      expect(rendered).to have_button(type: 'submit', name: 'manage_field[delete_field]', count: 3)
    end
  end
end
