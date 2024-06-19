require 'rails_helper'

RSpec.describe 'admin/configs/show' do
  before do
    assign(:config, Config.current)
  end

  it 'renders attributes as json' do
    render
    expect(rendered).to include(ERB::Util.html_escape('"description": "T3 Configuration export"'))
  end
end
