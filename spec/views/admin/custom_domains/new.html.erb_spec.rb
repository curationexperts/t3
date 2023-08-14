require 'rails_helper'

RSpec.describe 'admin/custom_domains/new' do
  before do
    assign(:custom_domain, CustomDomain.new)
  end

  it 'renders new domain form' do
    render
    expect(rendered).to have_selector("form[@action='#{custom_domains_path}']")
  end

  it 'accepts a domain name' do
    render
    expect(rendered).to have_field(id: 'custom_domain_host')
  end

  it 'has a submit button' do
    render
    expect(rendered).to have_button(type: 'submit')
  end
end
