require 'rails_helper'

RSpec.describe 'configs/show', :aggregate_failures do
  before do
    assign(:config, Config.create!(
                      solr_host: 'Solr Host',
                      solr_core: 'Solr Core',
                      solr_version: '3.2.1',
                      fields: 'some json here...'
                    ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Solr Host/)
    expect(rendered).to match(/Solr Core/)
    expect(rendered).to match(/json/)
  end
end
