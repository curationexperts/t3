require 'rails_helper'

RSpec.describe 'configs/edit' do
  let(:config) do
    Config.create!(
      solr_host: 'MyString',
      solr_core: 'MyString',
      solr_version: '3.2.1',
      fields: ''
    )
  end

  before do
    assign(:config, config)
  end

  it 'renders the edit config form' do
    render

    assert_select 'form[action=?][method=?]', config_path(config), 'post' do
      assert_select 'input[name=?]', 'config[solr_host]'
      assert_select 'input[name=?]', 'config[solr_core]'
    end
  end
end
