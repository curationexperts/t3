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
end
