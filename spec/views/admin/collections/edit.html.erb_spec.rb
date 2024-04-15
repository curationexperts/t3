require 'rails_helper'

RSpec.describe 'admin/items/edit', :solr do
  let(:blueprint) { FactoryBot.build(:blueprint, name: 'Simple Blueprint') }

  let(:collection) do
    FactoryBot.build(:collection,
                     id: 10,
                     blueprint: blueprint,
                     metadata: { 'Title' => '1 Print', 'keyword' => ['multivalue', 'test example'] })
  end

  before do
    stub_solr
    assign(:item, collection)
    allow(controller).to receive(:action_name).and_return('edit')
    allow(collection).to receive(:persisted?).and_return(true)
  end

  it 'displays a heading' do
    render
    expect(rendered).to have_selector('h1', text: 'Editing Collection')
  end

  it 'has a link to show the collection' do
    render
    expect(rendered).to have_link(href: collection_path(collection), text: /collection/i)
  end

  it 'has a link to return to the index listing' do
    render
    expect(rendered).to have_link(href: collections_path, text: /collections/i)
  end

  it 'renders an update form' do
    render
    expect(rendered).to have_selector("form[action='#{collection_path(collection)}'][method='post']")
  end

  it 'displays the (disabled) blueprint name' do
    # Imitate saving our blueprint
    allow(Blueprint).to receive(:order).and_return([blueprint])

    render
    expect(rendered).to have_field('item_blueprint_id', text: 'Simple Blueprint', disabled: true)
  end

  it 'displays fields in order' do
    allow(blueprint).to receive(:fields).and_return([
                                                      FactoryBot.build(:field, name: 'Title'),
                                                      FactoryBot.build(:field, name: 'Author'),
                                                      FactoryBot.build(:field, name: 'Format')
                                                    ])
    render
    input_fields = Capybara.string(rendered).all('input[@type!="submit"], textarea')
    field_ids = input_fields.pluck(:id)
    expect(field_ids).to eq ['item_metadata_Title', 'item_metadata_Author', 'item_metadata_Format']
  end

  it 'indiicates required inputs' do
    allow(blueprint).to receive(:fields).and_return([
                                                      FactoryBot.build(:field, name: 'Title', required: true),
                                                      FactoryBot.build(:field, name: 'Author'),
                                                      FactoryBot.build(:field, name: 'Format', required: true)
                                                    ])
    render
    input_fields = Capybara.string(rendered).all('label:has(span.required) input')
    field_ids = input_fields.pluck(:id)
    expect(field_ids).to eq ['item_metadata_Title', 'item_metadata_Format']
  end

  describe 'a text field' do
    let(:text_field) do
      FactoryBot.build(:field, name: 'abstract', data_type: 'text_en', multiple: false, id: 1, sequence: 1)
    end

    it 'renders as a textarea input' do
      allow(blueprint).to receive(:fields).and_return([text_field])
      render
      expect(rendered).to have_selector('textarea#item_metadata_abstract')
    end
  end

  describe 'a string field' do
    let(:string_field) do
      FactoryBot.build(:field, name: 'genre', data_type: 'string', multiple: true, id: 1, sequence: 1)
    end

    it 'renders as a text_field input' do
      allow(blueprint).to receive(:fields).and_return([string_field])
      render
      expect(rendered).to have_selector('input#item_metadata_genre_1[@type="text"]')
    end
  end

  describe 'a date field' do
    let(:date_field) { FactoryBot.build(:field, name: 'date', data_type: 'date', multiple: false, id: 1, sequence: 1) }

    it 'renders as a date_field input' do
      allow(blueprint).to receive(:fields).and_return([date_field])
      render
      expect(rendered).to have_selector('input#item_metadata_date[@type="date"]')
    end
  end

  describe 'a boolean field' do
    let(:boolean_field) do
      FactoryBot.build(:field, name: 'special_collections', data_type: 'boolean', multiple: false, id: 1, sequence: 1)
    end

    it 'renders as a checkbox' do
      allow(blueprint).to receive(:fields).and_return([boolean_field])
      render
      expect(rendered).to have_selector('input#item_metadata_special_collections[@type="checkbox"]')
    end
  end

  describe 'an integer field' do
    let(:integer_field) do
      FactoryBot.build(:field, name: 'year', data_type: 'integer', multiple: false, id: 1, sequence: 1)
    end

    it 'renders as a numeric field' do
      allow(blueprint).to receive(:fields).and_return([integer_field])
      render
      expect(rendered).to have_selector('input#item_metadata_year[@type="number"]')
    end
  end

  describe 'a float field' do
    let(:float_field) do
      FactoryBot.build(:field, name: 'score', data_type: 'float', multiple: false, id: 1, sequence: 1)
    end

    it 'renders as a numeric field' do
      allow(blueprint).to receive(:fields).and_return([float_field])
      render
      expect(rendered).to have_selector('input#item_metadata_score[@type="number"]')
    end
  end

  describe 'a multivalue field' do
    before do
      allow(collection.blueprint).to receive(:fields).and_return(
        [FactoryBot.build(:field, name: 'keyword', data_type: 'string', multiple: true)]
      )
    end

    # If the parameter name ends with an empty set of square brackets [] then they will be accumulated in an array
    # see https://guides.rubyonrails.org/form_helpers.html#basic-structures
    it 'returns values as an array' do
      render
      expect(rendered).to have_field('item[metadata][keyword][]', count: 2)
    end

    it 'renders each value in a separate input field' do
      render
      expect(rendered).to have_field('item_metadata_keyword_2', with: 'test example')
    end

    it 'has a button to add additional values' do
      render
      expect(rendered).to have_button('refresh', value: 'add keyword -1')
    end

    it 'has a button to delete each existing value' do
      render
      expect(rendered).to have_button('refresh', value: 'delete keyword 2')
    end
  end

  describe 'a vocabulary field' do
    let(:vocabulary_field) do
      FactoryBot.build(:field, name: 'collection', data_type: 'vocabulary', multiple: false, id: 1, sequence: 1)
    end

    before do
      collections = [
        instance_double(Collection, { id: 1, label: 'Cyan' }),
        instance_double(Collection, { id: 2, label: 'Magenta' }),
        instance_double(Collection, { id: 4, label: 'Yellow' })
      ]
      allow(Collection).to receive(:order).and_return(collections)
    end

    it 'renders a slection list' do
      allow(blueprint).to receive(:fields).and_return([vocabulary_field])
      render
      expect(rendered).to have_select('item[metadata][collection]')
    end

    it 'lists available values' do
      allow(blueprint).to receive(:fields).and_return([vocabulary_field])
      render
      select_options = Capybara.string(rendered).all('select option').map(&:text)
      expect(select_options).to include('Cyan', 'Magenta', 'Yellow')
    end
  end
end
