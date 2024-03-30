require 'rails_helper'

RSpec.describe 'admin/items/edit', :solr do
  let(:blueprint) { Blueprint.new(name: 'Simple Blueprint') }

  let(:item) do
    Item.create!(
      blueprint: blueprint,
      metadata: { 'Title' => '1 Print' }
    )
  end

  before do
    stub_solr
    assign(:item, item)
    allow(controller).to receive(:action_name).and_return('edit')
  end

  it 'displays a form' do
    render
    expect(rendered).to have_selector("form[action=\"#{item_path(item)}\"][method=\"post\"]")
  end

  it 'displays the (disabled) blueprint name' do
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
    let(:string_field) { FactoryBot.build(:field, name: 'keyword', data_type: 'string', multiple: true) }
    let(:item) do
      Item.create!(
        blueprint: blueprint,
        metadata: { 'Title' => '1 Print', 'keyword' => ['multivalue', 'test example'] }
      )
    end

    before do
      allow(blueprint).to receive(:fields).and_return([string_field])
    end

    it 'renders multiple inputs' do
      render
      expect(rendered).to have_field('item[metadata][keyword][]', count: 2)
    end

    # If the parameter name ends with an empty set of square brackets [] then they will be accumulated in an array
    # see https://guides.rubyonrails.org/form_helpers.html#basic-structures
    it 'returns an array in parameters' do
      render
      expect(rendered).to have_field('item_metadata_keyword_2', with: 'test example')
    end
  end
end
