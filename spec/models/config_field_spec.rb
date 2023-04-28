# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConfigField, :aggregate_failures do
  let(:new_field) { described_class.new }

  it 'has a name' do
    new_field.name = 'title_tsim'
    expect(new_field.name).to eq 'title_tsim'
  end

  it 'has a label' do
    new_field.label = 'Title'
    expect(new_field.label).to eq 'Title'
  end

  it 'indicates whether fields should be searched' do
    new_field.search = true
    expect(new_field.search).to be true
    new_field.search = 'false'
    expect(new_field.search).to be false
  end

  it 'indicates whether fields should be faceted' do
    new_field.facet = true
    expect(new_field.facet).to be true
    new_field.facet = 'false'
    expect(new_field.facet).to be false
  end

  it 'indicates whether fields should be displayed in index listings' do
    new_field.index = true
    expect(new_field.index).to be true
    new_field.index = 'false'
    expect(new_field.index).to be false
  end

  it 'indicates whether fields should be displayed in show views' do
    new_field.show = true
    expect(new_field.show).to be true
    new_field.show = 'false'
    expect(new_field.show).to be false
  end

  it 'provides label suggestions' do
    new_field.name = '__Rights-Statement_tsi'
    expect(new_field.suggested_label).to eq 'Rights Statement'
    new_field.name = '__title__'
    expect(new_field.suggested_label).to eq 'Title'
  end

  it 'serializes to JSON' do # rubocop:disable  RSpec/ExampleLength
    field = described_class.new(name: 'title_tesim', label: 'Title', search: true, show: true, index: true)
    expect(field.as_json).to eq({
                                  'name' => 'title_tesim',
                                  'label' => 'Title',
                                  'search' => true,
                                  'index' => true,
                                  'show' => true,
                                  'facet' => false
                                })
  end
end
