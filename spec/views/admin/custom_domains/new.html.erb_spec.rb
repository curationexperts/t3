require 'rails_helper'

RSpec.describe 'admin/custom_domains/new' do
  let(:custom_domain) { CustomDomain.new }

  before do
    assign(:custom_domain, custom_domain)
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

  describe 'shows errors for' do
    before do
      allow(Certbot::V2::Client).to receive(:new).and_return(Certbot::V2::TestClient.new)
    end

    example ':format' do
      custom_domain.errors.add(:host, :format)
      render
      expect(rendered).to have_selector('div#format')
    end

    example ':taken' do
      custom_domain.errors.add(:host, :taken)
      render
      expect(rendered).to have_selector('div#taken')
    end

    example ':unresolvable' do
      custom_domain.host = 'test.example.com'
      custom_domain.errors.add(:host, :unresolvable)
      render
      expect(rendered).to have_selector('div#unresolvable')
    end

    example ':certificate' do
      custom_domain.certbot_client.last_error = 'Something unexpected happened'
      custom_domain.errors.add(:host, :certificate)
      render
      expect(rendered).to have_selector('div#certificate')
    end
  end
end
