require 'rails_helper'

RSpec.describe 'configs/index' do
  before do
    assign(:configs, [
             Config.create!(
               solr_host: 'Solr Host',
               solr_core: 'Solr Core',
               solr_version: '3.2.1',
               fields: 'some json here...'
             ),
             Config.create!(
               solr_host: 'Solr Host',
               solr_core: 'Solr Core',
               solr_version: '3.2.1',
               fields: 'some json here...'
             )
           ])
  end

  it 'renders a list of configs' do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new('Solr Host'.to_s), count: 2
    assert_select cell_selector, text: Regexp.new('Solr Core'.to_s), count: 2
    assert_select cell_selector, text: Regexp.new('json'.to_s), count: 2
  end
end
