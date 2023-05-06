require 'rails_helper'

RSpec.describe 'configs/new' do
  before do
    assign(:config, Config.new(
                      solr_host: 'MyString',
                      solr_core: 'MyString',
                      fields: ''
                    ))
  end

  it 'renders new config form' do
    render

    assert_select 'form[action=?][method=?]', configs_path, 'post' do
      assert_select 'input[name=?]', 'config[solr_host]'
      assert_select 'input[name=?]', 'config[solr_core]'
    end
  end
end
