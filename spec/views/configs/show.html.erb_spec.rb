require 'rails_helper'

RSpec.describe 'configs/show', :aggregate_failures do
  let(:config) { FactoryBot.build(:config) }

  before do
    allow(config).to receive(:solr_host_responsive)
    config.save!
    assign(:config, config)
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/localhost/)
    expect(rendered).to match(/blacklight-core/)
    expect(rendered).to match(/FieldConfig/)
  end
end
