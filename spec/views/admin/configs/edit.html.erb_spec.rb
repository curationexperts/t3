require 'rails_helper'

RSpec.describe 'admin/configs/edit' do
  let(:config) do
    Config.current
  end

  before do
    assign(:config, config)
  end

  it 'renders the edit config form' do
    render
    expect(rendered).to have_selector("form[@action='#{config_path}']")
  end

  it 'accepts a json file' do
    render
    expect(rendered).to have_field('config_file')
  end

  it 'has a submit button' do
    render
    expect(rendered).to have_button(type: 'submit')
  end
end
