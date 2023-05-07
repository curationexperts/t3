require 'rails_helper'

RSpec.describe 'configs/new' do
  before do
    assign(:config, FactoryBot.build(:config, setup_step: 'host'))
  end

  it 'renders new config form', :aggregate_failures do
    render
    expect(rendered).to have_field('config[solr_host]')
    expect(rendered).to have_field('config[solr_core]', disabled: true)
  end
end
