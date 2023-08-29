require 'rails_helper'

RSpec.describe 'admin/configs/edit' do
  let(:config) { FactoryBot.build(:config) }

  before do
    allow(config).to receive(:solr_host_responsive)
    config.save!
    assign(:config, config)
    render
  end

  it 'renders the edit config form', :aggregate_failures do
    assert_select 'form[action=?][method=?]', config_path, 'post'
    expect(rendered).to have_field('config[solr_host]', disabled: true)
    expect(rendered).to have_field('config[solr_core]', disabled: true)
  end

  context 'with multiple fields' do
    let(:title_field) { FieldConfig.new(solr_field_name: 'title_tesi', solr_suffix: '*_tesi') }
    let(:keyword_field) { FieldConfig.new(solr_field_name: 'keyword_ssim', solr_suffix: '*_ssim') }
    let(:config) { FactoryBot.build(:config, fields: [title_field, keyword_field]) }

    it 'renders fields as a table' do
      expect(rendered).to have_table('field_configs')
    end

    it 'displays the solr field name as plain text' do
      expect(rendered).to have_selector 'td.name', text: 'title_tesi'
    end

    it 'round-trips non-editable fields as hidden fields', :aggregate_failures do
      expect(rendered).to have_field 'config_fields_attributes_1_solr_field_name', type: :hidden, with: 'keyword_ssim'
      expect(rendered).to have_field 'config_fields_attributes_1_solr_suffix', type: :hidden, with: '*_ssim'
    end

    it 'displays the label' do
      expect(rendered).to have_field 'config_fields_attributes_1_display_label', with: 'Keyword'
    end

    it 'displays whether the field is enabled' do
      expect(rendered).to have_checked_field 'config_fields_attributes_1_enabled'
    end

    it 'displays whether the field is searchable' do
      pending 'implement search configuration'
      expect(rendered).to have_checked_field 'config_fields_attributes_1_searchable'
    end

    it 'displays whether the field is facetable' do
      expect(rendered).to have_unchecked_field 'config_fields_attributes_1_facetable'
    end

    it 'displays whether the field is displayed in search results' do
      expect(rendered).to have_checked_field 'config_fields_attributes_1_search_results'
    end

    it 'displays whether the field is displayed on the single item view' do
      expect(rendered).to have_checked_field 'config_fields_attributes_1_item_view'
    end
  end
end
