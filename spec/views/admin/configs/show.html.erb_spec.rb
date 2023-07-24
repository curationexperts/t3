require 'rails_helper'

RSpec.describe 'admin/configs/show', :aggregate_failures do
  let(:config) { FactoryBot.build(:config) }

  before do
    allow(config).to receive(:solr_host_responsive)
    config.save!
    assign(:config, config)
    render
  end

  it 'displays the Solr host' do
    expect(rendered).to match(/localhost/)
  end

  it 'displays the Solr core' do
    expect(rendered).to match(/blacklight-core/)
  end

  context 'with multiple fields configured' do
    let(:title_field) { FieldConfig.new(solr_field_name: 'title_tesi', solr_suffix: '*_tesi') }
    let(:keyword_field) { FieldConfig.new(solr_field_name: 'keyword_ssim', solr_suffix: '*_ssim') }
    let(:config) { FactoryBot.build(:config, fields: [title_field, keyword_field]) }

    it 'renders fields as a table' do
      expect(rendered).to have_table('field_configs')
    end

    it 'displays the solr field name' do
      expect(rendered).to have_selector 'td.name', text: 'title_tesi'
    end

    it 'displays the label' do
      expect(rendered).to have_selector 'td.label', text: 'Keyword'
    end

    it 'displays whether the field is enabled' do
      expect(rendered).to have_checked_field 'fields[1][enabled]', disabled: true
    end

    it 'displays whether the field is searchable' do
      pending 'configurable search implementation'
      expect(rendered).to have_checked_field 'fields[1][searchable]', disabled: true
    end

    it 'displays whether the field is facetable' do
      expect(rendered).to have_unchecked_field 'fields[1][facetable]', disabled: true
    end

    it 'displays whether the field is displayed in search results' do
      expect(rendered).to have_checked_field 'fields[1][search_results]', disabled: true
    end

    it 'displays whether the field is displayed on the single item view' do
      expect(rendered).to have_checked_field 'fields[1][item_view]', disabled: true
    end
  end
end
