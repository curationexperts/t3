module Certbot
  module V2
    # Test class that makes no calls to external interfaces
    # Accessor methods allow setting dummy values for all
    # instance variables as required for testing
    class TestClient < Client
      attr_accessor :domains, :not_after, :last_error, :valid

      def initialize(domains: [], not_after: 1.day.from_now, last_error: nil, valid: true)
        super()
        @domains = [TestClient.default_host].concat(domains).uniq
        @not_after = not_after
        @last_error = last_error
        @valid = valid
      end

      private

      def update_hosts(new_hosts)
        Rails.logger.warn("TEST CLIENT: would have called Certbot with: #{CERTBOT_UPDATE + new_hosts}")
        @domains = new_hosts
        load_certificate && last_error.blank?
      end

      def load_certificate
        valid?
      end
    end
  end
end
