require 'rails_helper'

RSpec.describe 'admin/status/index.html.erb' do
  it 'has a button to download the configuration' do
    render
    expect(rendered).to have_link('export_config', href: config_path(format: :json), class: 'btn')
  end

  it 'has a button to import the configuration from a file' do
    render
    expect(rendered).to have_link('import_config', href: edit_config_path, class: 'btn')
  end
end
