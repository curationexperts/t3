require 'rails_helper'

RSpec.describe Field do
  let(:field) { FactoryBot.build(:field) }

  it 'has a vaild factory' do
    expect(field).to be_valid
  end

  describe 'default values' do
    let(:new_field) { described_class.new }

    it 'sets active = true' do
      expect(new_field.active).to be true
    end

    it 'sets required == false' do
      expect(new_field.required).to be false
    end

    it 'sets multiple == false' do
      expect(new_field.multiple).to be false
    end

    it 'sets searchable == true' do
      expect(new_field.searchable).to be true
    end

    it 'sets facetable == false' do
      expect(new_field.facetable).to be false
    end

    it 'sets list_view == false' do
      expect(new_field.list_view).to be false
    end

    it 'sets item_view == true' do
      expect(new_field.item_view).to be true
    end
  end

  describe '#name' do
    it 'must have a value' do
      field.name = nil
      field.valid?
      expect(field.errors.where(:name, :blank)).to be_present
    end

    it 'must be unique (case insensitive)' do
      FactoryBot.create(:field, name: 'first-field')
      second_field = FactoryBot.build(:field, name: 'First-Field')
      second_field.valid?
      expect(second_field.errors.where(:name, :taken)).to be_present
    end

    it 'cannot begin with a space or dash' do
      field.name = '-a field'
      field.valid?
      expect(field.errors.where(:name, :invalid)).to be_present
    end

    it 'cannot end with a space or dash' do
      field.name = 'a field-'
      field.valid?
      expect(field.errors.where(:name, :invalid)).to be_present
    end

    it 'can contain letters, numbers, and spaces or dashes' do
      field.name = 'Field 1 search-only'
      field.valid?
      expect(field.errors.where(:name, :invalid)).not_to be_present
    end

    it 'can not contain special characters' do
      field.name = 'here&there'
      field.valid?
      expect(field.errors.where(:name, :invalid)).to be_present
    end
  end

  describe '#data_type' do
    it 'must have a value' do
      field.data_type = nil
      field.valid?
      expect(field.errors.where(:data_type, :blank)).to be_present
    end

    it 'does not accept invalid values' do
      expect { field.data_type = 'irregular' }.to raise_exception ArgumentError
    end

    it 'accepts defined types' do
      expect { field.data_type = 'text' }.not_to raise_exception
    end

    it 'casts to a string when read' do
      field.data_type = :text
      expect(field.data_type).to eq 'text'
    end

    it 'has a class method to return valid values' do
      expect(described_class.data_types).to be_a Hash
    end
  end

  describe '#solr_suffix' do
    it 'ends in "m" for multivalued fields' do
      field.multiple = true
      expect(field.solr_suffix).to match(/m\z/)
    end

    it 'omits final "m" for singular fields' do
      field.multiple = false
      expect(field.solr_suffix).to match(/[^m]\z/)
    end

    it 'maps the field type' do
      field.data_type = 'date'
      expect(field.solr_suffix).to match(/\A_dt[sim]+\z/)
    end

    it 'does not tokenize strings' do
      field.data_type = 'string'
      expect(field.solr_suffix).to match(/\A_s[sim]+\z/)
    end

    it 'uses english token rules for text' do
      field.data_type = 'text'
      expect(field.solr_suffix).to match(/\A_te[sim]+\z/)
    end

    it 'has mappings for all field types' do
      expect(described_class.data_types.keys).to match_array described_class::TYPE_TO_SOLR.keys
    end
  end

  describe '#solr_field' do
    it 'returns a solr field name that matches dynamic field suffixes' do
      field.name = 'Year'
      field.data_type = 'integer'
      expect(field.solr_field).to eq 'year_ltsi'
    end

    it 'handles multiples' do
      field.name = 'Keyword'
      field.data_type = 'string'
      field.multiple = true
      expect(field.solr_field).to eq 'keyword_ssim'
    end

    it 'replaces dashes and spaces in the name with underscores' do
      field.name = 'Additional co-authors'
      field.data_type = 'text'
      field.multiple = true
      expect(field.solr_field).to eq 'additional_co_authors_tesim'
    end

    it 'is memoized' do
      memo = field.solr_field
      field.name = 'new_name'
      expect(field.solr_field).to eq memo
    end

    it 'clears memoization on save' do
      memo = field.solr_field
      field.name = "#{field.name} changed"
      field.save!
      expect(field.solr_field).not_to eq memo
    end
  end

  describe '#solr_facet_field' do
    it 'is the same as solr_field for non-text fields' do
      field.data_type = 'integer'
      expect(field.solr_facet_field).to eq field.solr_field
    end

    it 'does not tokenize text fields' do
      field.data_type = 'text'
      expect(field.solr_facet_field).to match(/_si\z/)
    end

    it 'respects multiple value fields' do
      field.data_type = 'text'
      field.multiple = true
      expect(field.solr_facet_field).to match(/_sim\z/)
    end

    it 'is memoized' do
      memo = field.solr_facet_field
      field.name = 'new_name'
      expect(field.solr_facet_field).to eq memo
    end

    it 'clears memoization on save' do
      memo = field.solr_facet_field
      field.name = "#{field.name} changed"
      field.save!
      expect(field.solr_facet_field).not_to eq memo
    end
  end
end
