require 'rails_helper'

# The CollectionsController inherits from ItemsController, so uses
# the items/views, but with a different controller name
RSpec.describe 'admin/items/new' do
  before do
    assign(:item, collection)
    allow(view).to receive(:controller_name).and_return('collections')
  end

  context 'without a blueprint' do
    let(:collection) { Collection.new }

    it 'prompts for blueprint selection' do
      render
      expect(rendered).to have_selector('#choose_blueprint')
    end
  end

  context 'with a blueprint' do
    let(:collection) { Collection.new(blueprint: Blueprint.first) }

    before do
      allow(collection.blueprint).to receive(:fields).and_return(
        [FactoryBot.build(:field, name: 'Title')]
      )
    end

    it 'displays a heading' do
      render
      expect(rendered).to have_selector('h1', text: 'New Collection')
    end

    it 'renders a creation form' do
      render
      expect(rendered).to have_selector("form[action='#{collections_path}'][method='post']")
    end

    it 'renders individual field inputs' do
      render
      expect(rendered).to have_field('item_metadata_Title')
    end

    it 'has a link to return to the index listing' do
      render
      expect(rendered).to have_link(href: collections_path, text: /collections/i)
    end
  end
end
