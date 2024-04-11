require 'rails_helper'

# The CollectionsController inherits from ItemsController, so uses
# the items/views, but with a different controller name
RSpec.describe 'admin/items/index' do
  let(:collections) do
    FactoryBot.build_list(:collection, 3) { |coll, i| coll.id = i }
  end

  before do
    allow(view).to receive(:controller_name).and_return('collections')
    collections.each { |coll| allow(coll).to receive(:persisted?).and_return(true) }
  end

  # An empty repository on initialization
  context 'with no collections' do
    before do
      assign(:items, [])
    end

    it 'displays the Collections heading' do
      render
      expect(rendered).to have_selector('h1', text: 'Collections')
    end

    it 'has a link to create a collection' do
      render
      expect(rendered).to have_link(href: new_collection_path, text: 'New collection')
    end
  end

  context 'with existing collections' do
    before do
      assign(:items, collections)
    end

    it 'renders a list of collections' do
      render
      expect(rendered).to have_selector('div.resource', count: 3)
    end

    it 'provides a link to each collection', :aggregate_failures do
      render
      expect(rendered).to have_selector('.resource a', count: 3)
      expect(rendered).to have_link(href: collection_path(collections[2]))
    end
  end
end
