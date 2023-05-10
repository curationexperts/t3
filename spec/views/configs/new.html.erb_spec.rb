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

  it 'renders the expected partials', :aggregate_failures do
    allow(view).to receive(:render).and_call_original
    render

    expect(view).to have_received(:render).with('host_form', any_args)
    expect(view).to have_received(:render).with('core_form', any_args)
    expect(view).to have_received(:render).with('fields_form', any_args)
  end
end
