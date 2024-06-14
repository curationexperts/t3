require 'rails_helper'

RSpec.describe 'configs/edit' do
  let(:config) do
    Config.current
  end

  before do
    assign(:config, config)
  end

  it 'renders the edit config form' do
    skip 'implement an upload feature'
  end
end
