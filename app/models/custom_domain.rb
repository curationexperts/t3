# Vanity Domains
class CustomDomain < ApplicationRecord
  validates :host, presence: true
  validates :host, uniqueness: true
  validate :validate_domain_resolvable
  validate :validate_certbot_success

  before_save :update_certificate

  def update_certificate
    success = certbot_client.add_host(host)
    raise ActiveRecord::RecordInvalid unless success
  end

  def certbot_client
    @certbot_client ||= Certbot::V2::Client.new
  end

  def validate_domain_resolvable
    return unless host

    if host =~ Certificate::DOMAIN_PATTERN
      Resolv.getaddress(host)
    else
      errors.add(:host, :format, message: 'must be a valid DNS hostname')
    end
  rescue Resolv::ResolvError
    errors.add(:host, :unresolvable, message: 'can not be resolved via DNS')
  end

  def validate_certbot_success
    if certbot_client.invalid?
      errors.add(:base, :certbot, message: 'could not initialize Certbot')
    elsif certbot_client.last_error.present?
      errors.add(:host, :certificate, message: "certificate update error text:\n#{certbot_client.last_error}")
    end
  end
end
