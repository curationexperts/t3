require 'rails_helper'

RSpec.describe 'admin/blueprints/edit' do
  let(:fields) { (0..2).map { FactoryBot.build(:field_config) } }
  let(:blueprint) { FactoryBot.create(:blueprint, fields: fields) }

  before do
    assign(:blueprint, blueprint)
    allow(controller).to receive(:action_name).and_return('edit')
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
      expect(rendered).to have_field('blueprint_fields_attributes_0_display_label', with: fields[0].display_label)
      expect(rendered).to have_field('blueprint_fields_attributes_2_display_label', with: fields[2].display_label)
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
