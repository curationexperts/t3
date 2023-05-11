require 'rails_helper'

RSpec.describe 'configs/edit' do
  let(:config) { FactoryBot.build(:config) }

  before do
    allow(config).to receive(:solr_host_responsive)
    config.save!
    assign(:config, config)
  end

  it 'renders the edit config form', :aggregate_failures do
    render
    assert_select 'form[action=?][method=?]', config_path(config), 'post'
    expect(rendered).to have_field('config[solr_host]', disabled: true)
    expect(rendered).to have_field('config[solr_core]', disabled: true)
  end
end