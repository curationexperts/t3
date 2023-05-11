require 'rails_helper'

RSpec.describe 'configs/index' do
  let(:config) { FactoryBot.build(:config) }
  let(:another) { FactoryBot.build(:config) }

  before do
    allow(config).to receive(:solr_host_responsive)
    config.save!
    allow(another).to receive(:solr_host_responsive)
    another.save!
    assign(:configs, [config, another])
  end

  it 'renders a list of configs' do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new('localhost'.to_s), count: 2
    assert_select cell_selector, text: Regexp.new('blacklight'.to_s), count: 2
    assert_select cell_selector, text: Regexp.new('FieldConfig'.to_s), count: 2
  end
end
