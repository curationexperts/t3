require 'rails_helper'

RSpec.describe CustomDomain do
  let(:domain) { described_class.new }
  let(:success) { Process.wait2(fork { Process.exit 0 })[1] }
  let(:certbot_stdout) do
    <<~STDOUT
      - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      Found the following matching certs:
        Certificate Name: t3.application
          Serial Number: 12345678901234567890123456789012345
          Key Type: ECDSA
          Domains: t3.example.com
          Expiry Date: 2023-11-12 19:15:08+00:00 (VALID: 89 days)
          Certificate Path: /etc/letsencrypt/live/t3.application/fullchain.pem
          Private Key Path: /etc/letsencrypt/live/t3.application/privkey.pem
      - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    STDOUT
  end
  let(:auth_failure) do
    <<~STDOUT
      Certbot failed to authenticate some domains (authenticator: apache). The Certificate Authority reported these problems:
        Domain: demo.tenejo.com
        Type:   unauthorized
        Detail: 50.16.172.231: Invalid response from https://demo.tenejo.com/.well-known/acme-challenge/sxzTJOsdmDKfInk7chxPpYj_9HWjEkEbInNP5ZFKTcY: 404

      Hint: The Certificate Authority failed to verify the temporary Apache configuration changes made by Certbot. Ensure that the listed domains point to this Apache server and that it is accessible from the internet.

      Some challenges have failed.
    STDOUT
  end

  before do
    # stub certbot certificate returning a single domain
    allow(Open3)
      .to receive(:capture2e)
      .with(Certbot::V2::Client::CERTBOT_READ)
      .and_return([certbot_stdout, success])
  end

  it 'has a host attribute' do
    expect(domain).to respond_to(:host=)
  end

  describe 'validation' do
    example 'checks host presence' do
      d1 = described_class.new(host: nil)
      d1.valid?
      expect(d1.errors.where(:host, :blank)).to be_present
    end

    example 'checks host uniqueness' do
      # Add the name to the table without calling other model logic
      described_class.insert({ host: 't3.example.com' })
      d1 = described_class.new(host: 't3.example.com')
      d1.valid?
      expect(d1.errors.where(:host, :taken)).to be_present
    end

    example 'checks certbot setup' do
      # stub certbot returning a partial update error
      allow(Open3).to receive(:capture2e).with(Certbot::V2::Client::CERTBOT_READ).and_return(['error', success])
      d1 = described_class.new(host: 'demo.tenejo.com')
      d1.valid?
      expect(d1.errors.where(:base, :certbot)).to be_present
    end

    example 'checks certbot errors' do
      # stub certbot returning a partial update error
      allow(Open3).to receive(:capture2e).with(Certbot::V2::Client::CERTBOT_UPDATE,
                                               anything).and_return([auth_failure, success])
      d1 = described_class.new(host: 'demo.tenejo.com')
      d1.save
      expect(d1.errors.where(:host, :certificate)).to be_present
    end
  end

  describe '#save' do
    before do
      # stub certbot returning a partial update error
      allow(Open3).to receive(:capture2e).with(Certbot::V2::Client::CERTBOT_UPDATE,
                                               anything).and_return([auth_failure, success])
    end

    it 'calls certbot with the hostname' do
      # stub out calls to certbot #add_host
      allow(domain.certbot_client).to receive(:add_host)
      domain.host = 'demo.tenejo.com'
      domain.save
      expect(domain.certbot_client).to have_received(:add_host).with('demo.tenejo.com')
    end

    it 'returns false on certbot failures', :aggregate_failures do
      domain.host = 'demo.tenejo.com'
      expect(domain.save).to be false
      expect(domain.errors).not_to be_nil
    end

    it 'returns the error on certbot failure' do
      domain.host = 'demo.tenejo.com'
      domain.save
      expect(domain.errors.where(:host, :certificate)).not_to be_nil
    end
  end
end
