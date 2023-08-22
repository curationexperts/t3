require 'rails_helper'

RSpec.describe CustomDomain do
  let(:domain) { described_class.new }
  let(:test_cert) { Certbot::V2::TestClient.new(domains: ['my-host.example.com'], not_after: 10.minutes.from_now) }
  let(:auth_failure) do
    <<~STDOUT
      Certbot failed to authenticate some domains (authenticator: apache). The Certificate Authority reported these problems:
        Domain: demo.tenejo.com
        Type:   unauthorized
        Detail: 50.16.172.231: Invalid response from https://demo.tenejo.com/.well-known/acme-challenge/sxzTJOsdmDKfInk7chxPpYj_9HWjEkEbInNP5ZFKTcY: 404

      Hint: The Certificate Authority failed to verify the temporary Apache configuration changes made by Certbot. Ensure that the listed domains point to this Apache server and that it is accessible from the internet.
    STDOUT
  end

  before do
    # stub certbot api calls
    allow(Certbot::V2::Client).to receive(:new).and_return(test_cert)
    allow(Resolv).to receive(:getaddress).and_return('10.10.0.1')
  end

  it 'has a host attribute' do
    expect(domain).to respond_to(:host=)
  end

  describe 'validation' do
    example 'checks host uniqueness' do
      # Add the name to the table without calling other model logic
      described_class.insert({ host: 't3.example.com' })
      d1 = described_class.new(host: 't3.example.com')
      d1.valid?
      expect(d1.errors.where(:host, :taken)).to be_present
    end

    example 'checks domain name format' do
      d1 = described_class.new(host: 'invalid-name-tenejo-com')
      d1.valid?
      expect(d1.errors.where(:host, :format)).to be_present
    end

    example 'checks DNS resoultion' do
      allow(Resolv).to receive(:getaddress).and_raise(Resolv::ResolvError)
      d1 = described_class.new(host: 'unresolvable.tenejo.com')
      d1.valid?
      expect(d1.errors.where(:host, :unresolvable)).to be_present
    end

    example 'checks certbot setup' do
      # stub certbot failing to read a local certificate
      test_cert.valid = false
      d1 = described_class.new(host: 'demo.tenejo.com')
      d1.valid?
      expect(d1.errors.where(:base, :certbot)).to be_present
    end

    example 'checks certbot errors' do
      # stub certbot returning a partial update error
      test_cert.last_error = auth_failure
      d1 = described_class.new(host: 'demo.tenejo.com')
      d1.save
      expect(d1.errors.where(:host, :certificate)).to be_present
    end
  end

  describe '#save' do
    it 'calls certbot with the hostname' do
      allow(domain.certbot_client).to receive(:add_host)
      domain.host = 'demo.tenejo.com'
      domain.save
      expect(domain.certbot_client).to have_received(:add_host).with('demo.tenejo.com')
    end

    context 'with certbot failures' do
      before do
        # stub certbot returning a partial update error
        test_cert.last_error = auth_failure
      end

      it 'returns false', :aggregate_failures do
        domain.host = 'demo.tenejo.com'
        expect(domain.save).to be false
        expect(domain.errors).not_to be_nil
      end

      it 'adds an error to the domain object' do
        domain.host = 'demo.tenejo.com'
        domain.save
        expect(domain.errors.where(:host, :certificate)).to be_present
      end
    end
  end
end
