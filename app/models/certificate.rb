# Wrapper to look up and read HTTPS (TLS) certificates
class Certificate
  DOMAIN_PATTERN = /(?<fqdn>(?:[a-z][a-z0-9-]{0,61}[a-z0-9]+\.)+[a-z0-9]{2,6})/i

  include ActiveModel::API

  attr_accessor :host, :x509cert

  validates :host, presence: true
  validates :host, format: { with: DOMAIN_PATTERN, message: 'must be a valid DNS hostname' }, allow_blank: true
  validate :host_can_be_resolved
  validates_each :x509cert do |rec, attr, val|
    rec.errors.add(attr, :missing_certificate, message: "certificate not returned by #{rec.host}") if val == :error
  end

  delegate :subject, :not_after, to: :@x509cert

  def initialize(attributes = nil)
    super
    @x509cert = fetch_cert(host)
  end

  # return the value of the CN portion of the subject as a domain string
  def subject_cn
    x509cert.subject.to_a.find { |e| e[0] = 'CN' }[1]
  end

  # return the value of any subject alternate names
  def subject_alt_names
    @subject_alt_names ||=
      x509cert.extensions.find { |e| e.oid == 'subjectAltName' }.value.scan(DOMAIN_PATTERN).flatten
    # Alternate implementation
    # x509cert.extensions.find { |e| e.oid == 'subjectAltName' }.value.split(', ').map { |h| h.sub('DNS:', '') }
  end

  private

  def fetch_cert(host)
    return :error unless valid?

    DefaultSession.fetch(host)
  end

  def host_can_be_resolved
    host&.match?(DOMAIN_PATTERN) && Resolv.getaddress(host).present?
  rescue Resolv::ResolvError
    errors.add(:host, :unresolvable, message: 'can not be resolved via DNS')
  end

  # Encapsulates Net::HTTP calls
  # so that we can stub external dependencies in tests
  class DefaultSession
    def self.fetch(host)
      http = Net::HTTP.new(host, 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      cert = nil
      http.start { |h| cert = h.peer_cert }
      cert || :error
    rescue StandardError => e
      Rails.logger.error(e)
      :error
    end
  end
end
