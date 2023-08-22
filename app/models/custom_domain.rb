# Vanity Domains
class CustomDomain < ApplicationRecord
  validate :domain_setup_ok?

  before_save :update_certificate

  def certbot_client
    @certbot_client ||= Rails.env.production? ? Certbot::V2::Client.new : Certbot::V2::TestClient.new
  end

  def update_certificate
    success = certbot_client.add_host(host)
    raise ActiveRecord::RecordInvalid unless success
  end

  private

  # Checks whether a certificate can be generated for the domain
  #
  # Adds a single error to the model representing the first failed process stage
  # because it would be redundant to add errors for successive stages
  # e.g. an improperly formatted host can never be resolved
  # and an unresolvable host can never be authenticated by certbot
  #
  # Error priority: (:base) :certbot, (:host) :format, :taken, :unresolvable, :certificate
  #
  # @return boolean True if domain passes all validations
  def domain_setup_ok?
    certbot_ok? && format_valid? && host_unique? && host_resolvable? && certificate_ok?
  end

  def certbot_ok?
    return true if certbot_client.valid?

    errors.add(:base, :certbot, message: 'could not initialize Certbot')
    false
  end

  def format_valid?
    return true if host =~ Certificate::DOMAIN_PATTERN

    errors.add(:host, :format, message: 'must be a valid DNS hostname')
    false
  end

  def host_unique?
    return true if CustomDomain.where(host: host).none?

    errors.add(:host, :taken, message: 'has already been taken')
    false
  end

  def host_resolvable?
    return true if Resolv.getaddress(host)

  # Resolv.getaddress raises an error on failures instead of returning a value
  rescue Resolv::ResolvError
    errors.add(:host, :unresolvable, message: 'can not be resolved via DNS')
    false
  end

  def certificate_ok?
    return true if certbot_client.last_error.blank?

    errors.add(:host, :certificate, message: "certificate update error text:\n#{certbot_client.last_error}")
    false
  end
end
