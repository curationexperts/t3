require 'open3'

module Certbot
  module V2
    # Wrapper for interacting with Certbot v2.x to manage TLS certificates
    #
    # This code makes a number of assumptions about interations with certbot:
    # 1) There will be an existing certificate setup on the server
    # 2) That certificate will always have the name 't3.application'
    # 3) That certificate will have the fully qualified host name as it's CN
    # 4) We are only interested in modifying domains listed at Subject Alternate Names
    # 5) We only add or remove domains one at at time (this may seem inefficient,but it
    #      maps directly to our current UX pattern)
    class Client
      # NOTE: The current implementation assumes the server uses a single previously issued
      # certificate with the certbot name 't3.application'
      CERTBOT_READ =
        'sudo certbot certificates --cert-name t3.application'.freeze
      CERTBOT_UPDATE =
        'sudo certbot certonly --apache -n --cert-name t3.application --allow-subset-of-names --domains '.freeze

      attr_reader :not_after, :last_error

      def self.default_host
        @default_host ||= `hostname -f`.chomp
      end

      def initialize
        load_certificate
        @last_error = nil
      end

      def valid?
        @valid
      end

      def invalid?
        !@valid
      end

      # Return the list of subject alternate name domains listed in the certificate
      # NOTE: letsencrypt & certbot use the term 'domain', we're using host to fit more
      # naturally with other rails network classes
      def hosts
        @domains
      end

      # add a single hostname to the website certificate
      def add_host(domain)
        return unless domain && valid?

        new_hosts = (@domains << domain).join(',')
        update_hosts(new_hosts)
      end

      # remove a single hostname from the website certificate
      def remove_host(domain)
        return unless @domains.include?(domain) && valid?

        new_hosts = (@domains - [domain]).join(',')
        update_hosts(new_hosts)
      end

      private

      # call certbot to update the list of domains (i.e. subject alternative names)
      def update_hosts(new_hosts)
        Rails.logger.warn("Calling Certbot with: #{CERTBOT_UPDATE + new_hosts}")
        response, status = Open3.capture2e(CERTBOT_UPDATE, stdin_data: new_hosts)
        Rails.logger.warn("Certbot returned: \n#{response}")
        @last_error = extract_errors(response, status)
        load_certificate
      end

      # call certbot to return a certificate summary
      def load_certificate
        Rails.logger.info("Calling Certbot with: #{CERTBOT_READ}")
        cert_summary, status = Open3.capture2e(CERTBOT_READ)

        @domains = extract_domains(cert_summary)
        @not_after = extract_expiration(cert_summary)
        @valid = not_after.present? && status.success?
      end

      # Extract domains from "certbot certificates" output
      def extract_domains(raw)
        parsed = raw.match(/Domains: (?<domains>[0-9a-z\-\. ]+)\n/)
        if parsed
          parsed[:domains]&.split
        else
          []
        end
      end

      # Extract expiration "certbot certificates" output
      def extract_expiration(raw)
        parsed = raw.match(/Expiry Date: (?<date>[0-9\- :+]+[0-9])\s+\(VALID/)
        Time.zone.parse(parsed[:date]) if parsed
      end

      # Extract errors if there was a partial update or outright failure
      # returns the error text or nil if there were no errors or failures
      def extract_errors(raw, status)
        if status.success?
          # a partial renewal was successful, the new domain failed authentication
          parsed =
            raw.match(/(?<failure>The Certificate Authority reported these problems(?:.+\n)+(?:\nHint: (?:.+\n)+)*)/)
          parsed[:failure] if parsed
        else
          # certbot exited with a an unexpected status code, so just return the full text
          raw
        end
      end
    end

    # Test class that makes no calls to external inerfaces
    # Accessor methods allow setting dummy values for all
    # instance variables
    class TestClient
      attr_accessor :hosts, :not_after, :last_error, :valid

      def initialize(hosts: [], not_after: Time.current, last_error: nil, valid: true)
        @hosts = hosts
        @not_after = not_after
        @last_error = last_error
        @valid = valid
      end

      def valid?
        !!valid
      end

      def invalid?
        !valid
      end

      def add_host(host)
        @hosts = hosts << host
      end

      def remove_host(host)
        @hosts = hosts - [host]
      end
    end
  end
end
