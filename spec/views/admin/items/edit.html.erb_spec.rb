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
    expect(field_ids).to eq ['metadata_Title', 'metadata_Author', 'metadata_Format']
  end

  it 'indiicates required inputs' do
    allow(blueprint).to receive(:fields).and_return([
                                                      FactoryBot.build(:field, name: 'Title', required: true),
                                                      FactoryBot.build(:field, name: 'Author'),
                                                      FactoryBot.build(:field, name: 'Format', required: true)
                                                    ])
    render
    input_fields = Capybara.string(rendered).all('label:has(span.required)')
    field_ids = input_fields.pluck(:for)
    expect(field_ids).to eq ['metadata_Title', 'metadata_Format']
  end

  describe 'a text field' do
    let(:text_field) do
      FactoryBot.build(:field, name: 'abstract', data_type: 'text_en', multiple: false, id: 1, sequence: 1)
    end

    it 'renders as a textarea input' do
      allow(blueprint).to receive(:fields).and_return([text_field])
      render
      expect(rendered).to have_selector('textarea#metadata_abstract')
    end
  end

  describe 'a string field' do
    let(:string_field) do
      FactoryBot.build(:field, name: 'genre', data_type: 'string', multiple: true, id: 1, sequence: 1)
    end

    it 'renders as a text_field input' do
      allow(blueprint).to receive(:fields).and_return([string_field])
      render
      expect(rendered).to have_selector('input#metadata_genre[@type="text"]')
    end
  end

  describe 'a date field' do
    let(:date_field) { FactoryBot.build(:field, name: 'date', data_type: 'date', multiple: false, id: 1, sequence: 1) }

    it 'renders as a date_field input' do
      allow(blueprint).to receive(:fields).and_return([date_field])
      render
      expect(rendered).to have_selector('input#metadata_date[@type="date"]')
    end
  end

  describe 'a boolean field' do
    let(:boolean_field) do
      FactoryBot.build(:field, name: 'special_collections', data_type: 'boolean', multiple: false, id: 1, sequence: 1)
    end

    it 'renders as a checkbox' do
      allow(blueprint).to receive(:fields).and_return([boolean_field])
      render
      expect(rendered).to have_selector('input#metadata_special_collections[@type="checkbox"]')
    end
  end

  describe 'an integer field' do
    let(:integer_field) do
      FactoryBot.build(:field, name: 'year', data_type: 'integer', multiple: false, id: 1, sequence: 1)
    end

    it 'renders as a numeric field' do
      allow(blueprint).to receive(:fields).and_return([integer_field])
      render
      expect(rendered).to have_selector('input#metadata_year[@type="number"]')
    end
  end

  describe 'an float field' do
    let(:float_field) do
      FactoryBot.build(:field, name: 'score', data_type: 'float', multiple: false, id: 1, sequence: 1)
    end

    it 'renders as a numeric field' do
      allow(blueprint).to receive(:fields).and_return([float_field])
      render
      expect(rendered).to have_selector('input#metadata_score[@type="number"]')
    end
  end
end
