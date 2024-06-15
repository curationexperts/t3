require 'rails_helper'

RSpec.describe 'admin/status/index.html.erb' do
  it 'has a button to download the configuration' do
    render
    expect(rendered).to have_link('export_config', href: config_url(format: :json), class: 'btn')
  end
end
