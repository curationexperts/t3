require 'rails_helper'

RSpec.describe Certbot::V2::Client do
  let(:certbot_captures) do
    {
      certificates2:
        <<~STDOUT,
          Saving debug log to /var/log/letsencrypt/letsencrypt.log

          - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          Found the following matching certs:
            Certificate Name: t3.application
              Serial Number: 12345678901234567890123456789012345
              Key Type: ECDSA
              Domains: t3-dev.example.com t3.university.edu
              Expiry Date: 2023-11-12 19:15:08+00:00 (VALID: 89 days)
              Certificate Path: /etc/letsencrypt/live/t3.application/fullchain.pem
              Private Key Path: /etc/letsencrypt/live/t3.application/privkey.pem
          - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        STDOUT
      certificates3:
        <<~STDOUT,
          Saving debug log to /var/log/letsencrypt/letsencrypt.log

          - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          Found the following matching certs:
            Certificate Name: t3.application
              Serial Number: 54321098765432109876543210987654321
              Key Type: ECDSA
              Domains: t3-dev.example.com t3.university.edu t3.example.com
              Expiry Date: 2023-11-12 19:46:32+00:00 (VALID: 89 days)
              Certificate Path: /etc/letsencrypt/live/t3.application/fullchain.pem
              Private Key Path: /etc/letsencrypt/live/t3.application/privkey.pem
          - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        STDOUT
      update_success:
        <<~STDOUT,
          Saving debug log to /var/log/letsencrypt/letsencrypt.log
          Renewing an existing certificate for t3-dev.example.com and 2 more domains

          Successfully received certificate.
          Certificate is saved at: /etc/letsencrypt/live/t3.application/fullchain.pem
          Key is saved at:         /etc/letsencrypt/live/t3.application/privkey.pem
          This certificate expires on 2023-11-13.
          These files will be updated when the certificate renews.
          Certbot has set up a scheduled task to automatically renew this certificate in the background.

          - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          If you like Certbot, please consider supporting our work by:
           * Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
           * Donating to EFF:                    https://eff.org/donate-le
          - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        STDOUT
      update_partial:
        <<~STDOUT,
          Saving debug log to /var/log/letsencrypt/letsencrypt.log
          Renewing an existing certificate for t3-dev.example.com and 2 more domains

          Certbot failed to authenticate some domains (authenticator: apache). The Certificate Authority reported these problems:
              Domain: demo.tenejo.com
              Type:   unauthorized
              Detail: 50.16.172.231: Invalid response from https://demo.tenejo.com/.well-known/acme-challenge/sxzTJOsdmDKfInk7chxPpYj_9HWjEkEbInNP5ZFKTcY: 404

          Hint: The Certificate Authority failed to verify the temporary Apache configuration changes made by Certbot.#{' '}
          Ensure that the listed domains point to this Apache server and that it is accessible from the internet.

          Unable to obtain a certificate with every requested domain. Retrying without: demo.tenejo.com

          Successfully received certificate.
          Certificate is saved at: /etc/letsencrypt/live/t3.application/fullchain.pem
          Key is saved at:         /etc/letsencrypt/live/t3.application/privkey.pem
          This certificate expires on 2023-11-13.
          These files will be updated when the certificate renews.
          Certbot has set up a scheduled task to automatically renew this certificate in the background.

          - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          If you like Certbot, please consider supporting our work by:
           * Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
           * Donating to EFF:                    https://eff.org/donate-le
          - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        STDOUT
      update_error:
        <<~STDOUT,
          Saving debug log to /var/log/letsencrypt/letsencrypt.log
          Renewing an existing certificate for t3-dev.example.com and 4 more domains
          An unexpected error occurred:
          Error creating new order :: Cannot issue for "foo-tenejo-com": Domain name needs at least one dot
          Ask for help or search for solutions at https://community.letsencrypt.org. See the logfile /var/log/letsencrypt/letsencrypt.log or re-run Certbot with -v for more details.
        STDOUT
      unexpected: 'Not what we were expecting...'
    }
  end

  let(:status_failed) { Process.wait2(fork { Process.exit 5 })[1] }
  let(:status_successful) { Process.wait2(fork { Process.exit 0 })[1] }
  let(:status) { status_successful }
  let(:certbot_stdout) { certbot_captures[:certificates2] }

  before do
    # stub certbot certinfo calls
    allow(Open3).to receive(:capture2e).with(Certbot::V2::Client::CERTBOT_READ).and_return([certbot_stdout, status])
  end

  describe '.default_host' do
    it 'returns the hostname configured on the server' do
      allow(described_class).to receive(:`).with('hostname -f').and_return("fqdn.example.com\n")

      expect(described_class.default_host).to eq 'fqdn.example.com'
    end
  end

  describe '.new' do
    it 'returns a client for the defualt certificate' do
      expect(described_class.new).to be_a described_class
    end

    it 'returns a valid client' do
      expect(described_class.new).to be_valid
    end

    context 'when certbot gives an unexpected response' do
      let(:certbot_stdout) { certbot_captures[:unexpected] }

      it 'returns a non-valid client' do
        expect(described_class.new).not_to be_valid
      end
    end

    context 'when certbot exits with an error code' do
      let(:status) { status_failed }

      it 'returns a non-valid client' do
        expect(described_class.new).not_to be_valid
      end
    end
  end

  describe '#hosts' do
    it 'returns the list of subject alternate names in the certificate' do
      cert_client = described_class.new
      expect(cert_client.hosts).to contain_exactly('t3-dev.example.com', 't3.university.edu')
    end
  end

  describe '#not_after' do
    it 'returns the expiration date for the certificate' do
      cert_client = described_class.new
      expect(cert_client.not_after).to eq Time.zone.parse('2023-11-12 19:15:08+00:00')
    end
  end

  describe '#add_host' do
    before do
      # stub certbot certificate returning 2 domains, then 3 domains
      allow(Open3)
        .to receive(:capture2e)
        .with(Certbot::V2::Client::CERTBOT_READ)
        .and_return(
          [certbot_captures[:certificates2], status_successful],
          [certbot_captures[:certificates3], status_successful]
        )
    end

    context 'when certbot certonly returns without error' do
      before do
        # stub a successful call to 'certbot certonly'
        allow(Open3).to receive(:capture2e).with(Certbot::V2::Client::CERTBOT_UPDATE,
                                                 anything).and_return([certbot_captures[:update_success], status])
      end

      it 'updates the domains on the certificate' do
        cert_client = described_class.new
        initial_domains = cert_client.hosts.dup

        cert_client.add_host('t3.example.com')
        difference = cert_client.hosts - initial_domains
        expect(difference).to eq ['t3.example.com']
      end

      it 'calls certbot update' do
        cert_client = described_class.new
        cert_client.add_host('t3.example.com')
        expect(Open3).to have_received(:capture2e).with(Certbot::V2::Client::CERTBOT_UPDATE, anything).once
      end

      it 'does nothing when the host is nil' do
        cert_client = described_class.new
        cert_client.add_host(nil)
        expect(Open3).not_to have_received(:capture2e).with(Certbot::V2::Client::CERTBOT_UPDATE, anything)
      end
    end

    context 'when certbot returns an error' do
      before do
        # stub certbot exiting with error (invalid domain name)
        allow(Open3)
          .to receive(:capture2e)
          .with(Certbot::V2::Client::CERTBOT_UPDATE,
                { stdin_data: 't3-dev.example.com,t3.university.edu,foo-tenejo-com' })
          .and_return([certbot_captures[:update_error], status_failed])
      end

      it 'passes the error message' do
        cert_client = described_class.new
        cert_client.add_host('foo-tenejo-com')
        expect(cert_client.last_error).to include 'Error creating new order'
      end
    end

    context 'when certbot can not verify the domain' do
      before do
        # stub certbot unable to verify one of three domains (host validation failure)
        allow(Open3)
          .to receive(:capture2e)
          .with(Certbot::V2::Client::CERTBOT_UPDATE, anything)
          .and_return([certbot_captures[:update_partial], status_successful])
      end

      it 'passes the failure reason' do
        cert_client = described_class.new
        cert_client.add_host('3-dev.example.com')
        expect(cert_client.last_error).to include 'the listed domains point to this Apache server'
      end
    end
  end

  describe '#remove_host' do
    before do
      # stub certbot certificate returning 3 domains, then 2 domains
      allow(Open3)
        .to receive(:capture2e)
        .with(Certbot::V2::Client::CERTBOT_READ)
        .and_return(
          [certbot_captures[:certificates3], status_successful],
          [certbot_captures[:certificates2], status_successful]
        )
    end

    context 'when certbot certonly returns without error' do
      before do
        allow(Open3).to receive(:capture2e).with(Certbot::V2::Client::CERTBOT_UPDATE,
                                                 anything).and_return([certbot_captures[:update_success], status])
      end

      it 'updates the domains' do
        cert_client = described_class.new
        initial_domains = cert_client.hosts.dup

        cert_client.remove_host('t3.example.com')
        difference = initial_domains - cert_client.hosts
        expect(difference).to eq ['t3.example.com']
      end

      it 'calls certbot update' do
        cert_client = described_class.new
        cert_client.remove_host('t3.university.edu')
        expect(Open3).to have_received(:capture2e).with(Certbot::V2::Client::CERTBOT_UPDATE, anything).once
      end

      it 'does nothing when the host is not in the existing certificate' do
        cert_client = described_class.new
        cert_client.remove_host('my-host.example.com')
        expect(Open3).not_to have_received(:capture2e).with(Certbot::V2::Client::CERTBOT_UPDATE, anything)
      end
    end

    context 'when certbot gives an unexpected response' do
      before do
        # stub a certbot non-zero exit and error message
        allow(Open3)
          .to receive(:capture2e)
          .with(Certbot::V2::Client::CERTBOT_UPDATE, anything)
          .and_return([certbot_captures[:update_error], status_failed])
      end

      it 'passes the error message' do
        cert_client = described_class.new
        cert_client.remove_host('t3.university.edu')
        expect(cert_client.last_error).to include 'Error creating new order'
      end
    end
  end
end
