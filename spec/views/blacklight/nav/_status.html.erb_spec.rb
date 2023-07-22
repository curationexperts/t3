require 'rails_helper'

RSpec.describe 'blacklight/nav/_status' do
  example 'no link for users without read dashboard ability' do
    allow(view.controller.current_ability).to receive(:can?).with(:read, :dashboard).and_return(false)
    render
    expect(rendered).not_to have_link(href: status_path)
  end

  it 'shows link for users with read dashboard ability' do
    allow(view.controller.current_ability).to receive(:can?).with(:read, :dashboard).and_return(true)
    render
    expect(rendered).to have_link(href: status_path)
  end
end
