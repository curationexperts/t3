require 'rails_helper'

RSpec.describe 'admin/custom_domains/index' do
  let(:domains) { (1..3).collect { |i| FactoryBot.build(:custom_domain, id: i) } }

  before { assign(:custom_domains, domains) }

  it 'renders a list of domains' do
    render
    expect(rendered).to have_selector('td.host', count: 3)
  end

  it 'has links to delte each domain' do
    render
    expect(rendered).to have_button('delete_custom_domain_3')
  end

  it 'has a link to add a domain' do
    render
    expect(rendered).to have_link('new_domain')
  end

  it 'displays the default domain' do
    pending 'certificate implementation'
    render
    expect(rendered).to have_selector('default_domain', text: 't3.curationexperts.com')
  end

  it 'displays the certificate expiration' do
    pending 'certificate implementation'
    render
    expect(rendered).to have_selector('not_valid_after', text: '3 days from now')
  end
end
