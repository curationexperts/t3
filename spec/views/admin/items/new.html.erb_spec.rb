require 'rails_helper'

RSpec.describe 'admin/items/new' do
  before do
    assign(:item, item)
  end

  context 'without a blueprint' do
    let(:item) { Item.new }

    it 'prompts for blueprint selection' do
      render
      expect(rendered).to have_selector('#choose_blueprint')
    end
  end

  context 'with a blueprint' do
    let(:item) { Item.new(blueprint: Blueprint.first) }

    it 'renders field inputs' do
      render
      expect(rendered).to have_selector('form')
    end
  end
end
