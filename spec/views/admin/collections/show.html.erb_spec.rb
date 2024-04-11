require 'rails_helper'

# The CollectionsController inherits from ItemsController, so uses
# the items/views, but with a different controller name
RSpec.describe 'admin/items/show' do
  let(:collection) { FactoryBot.build(:collection, id: 1) }

  before do
    assign(:item, collection)
    allow(collection).to receive(:persisted?).and_return(true)
    allow(collection.blueprint).to receive(:fields).and_return(
      [FactoryBot.build(:field, name: 'Title')]
    )
  end

  it 'renders the metadata' do
    render
    expect(rendered).to include 'Unremarkable Collection' # see collection factory
  end

  it 'displays the blueprint name' do
    render
    expect(rendered).to match(/basic_blueprint/) # see blueprint factory
  end

  it 'has a link to edit the collection' do
    render
    expect(rendered).to have_link(href: edit_collection_path(collection), text: /collection/i)
  end

  it 'has a link to return to the index listing' do
    render
    expect(rendered).to have_link(href: collections_path, text: /collections/i)
  end

  it 'has a button to delete the collection' do
    render
    expect(rendered).to have_button(dom_id(collection, :delete), text: /collection/i)
  end
end
