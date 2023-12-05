require 'rails_helper'

RSpec.describe Certificate, :aggregate_failures do
  let(:test_cert) do
    OpenSSL::X509::Certificate.new.tap do |cert|
      cert.version = 2
      cert.serial = 1
      cert.subject = OpenSSL::X509::Name.new([['CN', 'test.example.com'], ['O', 'example.com']])
      cert.not_before = Time.current
      cert.not_after = 5.minutes.from_now
      ef = OpenSSL::X509::ExtensionFactory.new
      ef.subject_certificate = cert
      ef.issuer_certificate = cert
      cert.add_extension(ef.create_extension('subjectAltName', 'DNS:host.example.com,DNS:text.example.com'))
    end
  end

  # Convenience method to stub out remote calls for an
  # HTTP-only host interaction
  def stub_http_only_host
    allow(Resolv).to receive(:getaddress).and_return('127.0.0.1')
    http = Net::HTTP.new(host: 'host.example.com')
    allow(http).to receive(:start).and_return(nil)
    allow(Net::HTTP).to receive(:new).and_return(http)
  end

  # This one test makes live connections over the public internet
  # to ensure our logic and syntax are valid. The remaining tests
  # stub out all internet calls
  it 'returns the certificate for a host' do
    cert = described_class.new(host: 'status.circleci.com')
    expect(cert).to be_valid
    expect(cert.not_after).to be > Time.current
  end

  it 'requires a host' do
    cert = described_class.new(host: nil)
    expect(cert).not_to be_valid
    expect(cert.errors.where(:host, :blank)).to be_present
  end

  it 'errors on invalid host names' do
    cert = described_class.new(host: 'not_a_valid_hostname')
    expect(cert).not_to be_valid
    expect(cert.errors.where(:host, :invalid)).to be_present
  end

  it 'errors on unresolvable hosts' do
    # stub Resolve call to simulate name resolution failure
    allow(Resolv).to receive(:getaddress).and_raise(Resolv::ResolvError)
    cert = described_class.new(host: 'my-machine.local')
    expect(cert).not_to be_valid
    expect(cert.errors.where(:host, :unresolvable)).to be_present
  end

  it 'errors on hosts without TLS certificates' do
    stub_http_only_host

    cert = described_class.new(host: 'host.example.com')
    expect(cert).not_to be_valid
    expect(cert.errors.where(:x509cert, :missing_certificate)).to be_present
  end

  it 'errors on NET::HTTP exceptions' do
    # stub the resolution call for a non-live host
    allow(Resolv).to receive(:getaddress).and_return('127.0.0.1')

    cert = described_class.new(host: 'host.example.com')
    expect(cert).not_to be_valid
    expect(cert.errors.where(:x509cert, :missing_certificate)).to be_present
  end

  describe 'with an x509 response' do
    # Stub out host resolution and certificate calls so that we can
    # run in isolation from external dependencies
    before do
      allow(Resolv).to receive(:getaddress).and_return('127.0.0.1')
      allow(Certificate::DefaultSession).to receive(:fetch).and_return(test_cert)
    end

    example 'delegates #not_after' do
      cert = described_class.new(host: 'host.example.com')
      expect(cert.not_after).to be > Time.current
    end

    it 'delegates #subject' do
      cert = described_class.new(host: 'host.example.com')
      expect(cert.subject.to_s).to match 'test'
    end

    it 'extracts #subject_cn' do
      cert = described_class.new(host: 'host.example.com')
      expect(cert.subject_cn).to eq 'test.example.com'
    end

    it 'extracts #subject_alt_names' do
      cert = described_class.new(host: 'host.example.com')
      expect(cert.subject_alt_names).to eq ['host.example.com', 'text.example.com']
    end
  end
end
